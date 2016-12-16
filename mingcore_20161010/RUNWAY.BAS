WHILE TRUE
    begin_deg = VR(100)
    end_deg = VR(101)
    range_deg = VR(101) - VR(100)
    dif_h = VR(102)
    safe_pos = VR(211)
    mode = VR(7)

    wp_l = VR(302)
    wp_w = VR(303)

    'runway mode
    IF mode = 4 THEN
        rec_l = VR(150)
        rec_w = VR(151)
        nturns = VR(152)
        offset_ang = VR(153)
        grinder_r = VR(154)
        home2c_dis = VR(155)
    ENDIF

    IF compute_done = 0 THEN
        GOSUB create_table
        compute_done = 1
        VR(304) = 1
    ENDIF

    IF IN(20) = ON AND flag_in_20 = 0 THEN
        flag_in_20 = 1
        cur_speed = SPEED AXIS(0)
        set_speed = (3600 * nturns / range_deg) * cur_speed * 5
        'set_speed = (3600 * nturns / range_deg) * cur_speed * 4
        SPEED AXIS(1) = set_speed
        ACCEL AXIS(1) = 20 * SPEED AXIS(1)
        DECEL AXIS(1) = ACCEL AXIS(1)
        start = 1
        VR(307) = 1
    ENDIF
    IF IN(20) = OFF THEN
        flag_in_20 = 0
    ENDIF

    IF start = 1 THEN
        'start: adjust clamp angle for cut
        BASE(1)
        MOVE(offset_ang+phi1_d)
        WAIT IDLE
        'profile: execute cam
        FOR turn = nturns - 1 TO 0 STEP -1
            cut_depth = max_cut * turn / nturns
            BASE(2)
            'SPEED=200*45
            SPEED=200*50
            ACCEL=SPEED*25
            DECEL=ACCEL
            MOVEABS(TABLE(0) - cut_depth)
            WAIT IDLE

            CAMBOX(0, 2 * pt_num-1, 10800*16/200, 3600, 1) AXIS(2)
            BASE(1)
            MOVE(3600)
            WAIT LOADED
            IF (turn = nturns - 1) THEN
                OP(9, 1)
            ENDIF
            IF (turn = 0) THEN
                OP(9, 0)
            ENDIF
            WAIT IDLE
        NEXT turn
        'end: return to safe position
        BASE(2)
        MOVEABS(safe_pos)
        WAIT IDLE
        BASE(1)
        MOVE(-offset_ang-phi1_d)
        WAIT IDLE
        start = 0
        VR(307) = 0
        VR(5)=VR(5)+1
        VR(6)=VR(5)
    ENDIF
WEND

init_para1:
r = grinder_r
h = dif_h
h2c = home2c_dis
c2c = h2c + SQR(r * r - h * h)
max_cut = (wp_w - rec_w) / 2
RETURN

init_para2:
w = rec_w
l = rec_l
RETURN

compute_angle:
c = l / 2 - w / 2
l = l - w
delta = (4*w*h+8*r*h)*(4*w*h+8*r*h)-4*(w*w+4*w*r+4*r*r+l*l)*(4*h*h-l*l)
num1 = 4*w*h+8*r*h-SQR(delta)
num2 = 4*w*h+8*r*h+SQR(delta)
den = 2*(w*w+4*w*r+4*r*r+l*l)
alpha1 = ASIN(num1/den)
alpha2 = ASIN(num2/den)
beta = -PI / 2
RETURN

create_table:
pt_num = 3600
table_start = 0
GOSUB init_para1
GOSUB init_para2
GOSUB compute_angle
phi1 = alpha1
phi2 = alpha2
phi1_d = phi1 * 1800 / PI
phi2_d = phi2 * 1800 / PI
'create cam table
FOR i = 0 TO pt_num - 1
    alpha = phi1 + PI * i / (pt_num - 1)
    IF alpha >= phi1 AND alpha < phi2 THEN
        phi = alpha
        dis=w/(2*COS(phi))+r/COS(phi)-h/(SIN(phi)*COS(phi))+h*COS(phi)/SIN(phi)
        dis2go = c2c - dis
        TABLE(table_start + i, dis2go)
    ENDIF
    IF alpha >= phi2 AND alpha <= PI + phi1 THEN
        phi = alpha
        x = COS(beta+phi)*c
        y = SIN(beta+phi)*c
        t1 = (y-h)*(y-h)
        t2 = (r+w/2)*(r+w/2)
        delta_r = (2*x)*(2*x)-4*(t1-t2+x*x)
        dis=(2*x+SQR(delta_r))/2
        dis2go = c2c - dis
        TABLE(table_start + i, dis2go)
    ENDIF
NEXT i
'table reversion
FOR i = 0 TO pt_num / 2 - 1
    temp = TABLE(i)
    TABLE(i, TABLE(pt_num - 1 - i))
    TABLE(pt_num - 1 - i, temp)
NEXT i

FOR i = 0 TO pt_num - 1
    TABLE(table_start + pt_num + i, TABLE(i))
NEXT i
RETURN
