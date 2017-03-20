WHILE TRUE
    begin_deg = VR(100)
    end_deg = VR(101)
    range_deg = VR(101) - VR(100)
    dif_h = VR(102)
    safe_pos = VR(211)

    wp_l = VR(302)
    wp_w = VR(303)

    rec_l = VR(170)
    rec_w = VR(171)
    nturns = VR(172)
    offset_ang = VR(173)
    grinder_r = VR(176)
    home2c_dis = VR(177)

    IF compute_done = 0 THEN
        GOSUB create_table
        compute_done = 1
        VR(304) = 1
    ENDIF

    IF IN(20) = ON AND flag_in_20 = 0 THEN
        flag_in_20 = 1
        'cur_speed = SPEED AXIS(0)
        cur_speed = SPEED AXIS(2)
        set_speed = (3600 * nturns / range_deg) * cur_speed * 3
        SPEED AXIS(1) = set_speed
        ACCEL AXIS(1) = 10 * SPEED AXIS(1)
        DECEL AXIS(1) = ACCEL AXIS(1)
        start = 1
        VR(307) = 1
    ENDIF
    IF IN(20) = OFF THEN
        flag_in_20 = 0
    ENDIF

    IF start = 1 THEN
        BASE(1)
        MOVE(offset_ang)
        WAIT IDLE
        DEFPOS(0)
        WAIT UNTIL MPOS AXIS(1)=0
        FOR turn = nturns - 1 TO 0 STEP -1
            '----------------------------------------
            cut_depth = max_cut * turn / nturns
            'BASE(1, 2)
            BASE(1, 0)
            MOVEABS(a1_start2d, wait_pos - cut_depth)
            WAIT IDLE

            'BASE(2)
            BASE(0)
            SPEED=200*25
            ACCEL=SPEED*10
            DECEL=ACCEL
            MOVEABS(TABLE(0) - cut_depth)
            WAIT IDLE

            'CAMBOX(0, pt_num - 1, 5000 * 16 / 200, (a1_end2d - a1_start2d), 1) AXIS(2)
            CAMBOX(0, pt_num - 1, 2048 * 16 / 200, (a1_end2d - a1_start2d), 1) AXIS(0)
            BASE(1)
            MOVEABS(a1_end2d)
            WAIT IDLE
            '----------------------------------------
            'BASE(2)
            BASE(0)
            MOVEABS(wait_pos - cut_depth)
            WAIT IDLE

            BASE(1)
            MOVEABS(0.5 * 1800 + a2_start2d)
            WAIT IDLE

            'BASE(2)
            BASE(0)
            MOVEABS(TABLE(pt_num) - cut_depth)
            WAIT IDLE

            'CAMBOX(pt_num, 2 * pt_num - 1, 5000 * 16 / 200, (a2_end2d - a2_start2d), 1) AXIS(2)
            CAMBOX(pt_num, 2 * pt_num - 1, 2048 * 16 / 200, (a2_end2d - a2_start2d), 1) AXIS(0)
            BASE(1)
            MOVEABS(0.5 * 1800 + a2_end2d)
            WAIT IDLE
            '----------------------------------------
            'BASE(1, 2)
            BASE(1, 0)
            MOVEABS(1800 + a1_start2d, wait_pos - cut_depth)
            WAIT IDLE

            'BASE(2)
            BASE(0)
            MOVEABS(TABLE(0) - cut_depth)
            WAIT IDLE

            'CAMBOX(0, pt_num - 1, 5000 * 16 / 200, (a1_end2d - a1_start2d), 1) AXIS(2)
            CAMBOX(0, pt_num - 1, 2048 * 16 / 200, (a1_end2d - a1_start2d), 1) AXIS(0)
            BASE(1)
            MOVEABS(1800 + a1_end2d)
            WAIT IDLE
            '----------------------------------------
            'BASE(2)
            BASE(0)
            MOVEABS(wait_pos - cut_depth)
            WAIT IDLE

            BASE(1)
            MOVEABS(1.5 * 1800 + a2_start2d)
            WAIT IDLE

            'BASE(2)
            BASE(0)
            MOVEABS(TABLE(pt_num) - cut_depth)
            WAIT IDLE

            'CAMBOX(pt_num, 2 * pt_num - 1, 5000 * 16 / 200, (a2_end2d - a2_start2d), 1) AXIS(2)
            CAMBOX(pt_num, 2 * pt_num - 1, 2048 * 16 / 200, (a2_end2d - a2_start2d), 1) AXIS(0)
            BASE(1)
            MOVEABS(1.5 * 1800 + a2_end2d)
            WAIT IDLE
            '----------------------------------------
            'BASE(1, 2)
            BASE(1, 0)
            MOVEABS(2 * 1800, wait_pos - cut_depth)
            WAIT LOADED
            IF (turn = nturns - 1) THEN
                OP(9, 1)
            ENDIF
            IF (turn = 0) THEN
                OP(9, 0)
            ENDIF
            WAIT IDLE
        NEXT turn
        BASE(1)
        MOVE(-offset_ang)
        WAIT IDLE
        BASE(1)
        DEFPOS(0)
        WAIT UNTIL DPOS AXIS(1)=0
        start = 0
        VR(307) = 0
        VR(5)=VR(5)+1
        VR(6)=VR(5)
    ENDIF
WEND

init_para:
r = grinder_r
h = dif_h
h2c = home2c_dis
c2c = h2c + SQR(r * r - h * h)
w = rec_w
l = rec_l
max_cut = (wp_w - rec_w) / 2
wait_dis = SQR((SQR((w/2)*(w/2)+(l/2)*(l/2))+r)*(SQR((w/2)*(w/2)+(l/2)*(l/2))+r)-h*h)
'wait_pos = c2c - wait_dis
wait_pos = 210
RETURN

swap_para:
temp = w
w = l
l = temp
RETURN

compute_angle:
delta = (4*w*h+8*r*h)*(4*w*h+8*r*h)-4*(w*w+4*w*r+4*r*r+l*l)*(4*h*h-l*l)
num1 = 4*w*h+8*r*h-SQR(delta)
num2 = 4*w*h+8*r*h+SQR(delta)
den = 2*(w*w+4*w*r+4*r*r+l*l)
a1 = ASIN(num1/den)
a2 = ASIN(num2/den)
RETURN

create_table:
i = 0
pt_num = 120
table_start = 0
GOSUB init_para
GOSUB compute_angle
a1_start = a1
a1_end = a2
a1_start2d = a1_start * 1800 / PI
a1_end2d = a1_end * 1800 / PI
FOR i = 0 TO pt_num - 1
    a = a1_start + (a1_end - a1_start) * i / (pt_num - 1)
    dis=w/(2*COS(a))+r/COS(a)-h/(SIN(a)*COS(a))+h*COS(a)/SIN(a)
    dis2go = c2c - dis
    TABLE(table_start + i, dis2go)
NEXT i
'table reversion
FOR i = 0 TO pt_num / 2 - 1
    temp = TABLE(table_start + i)
    TABLE(table_start + i, TABLE(table_start + pt_num - 1 - i))
    TABLE(table_start + pt_num - 1 - i, temp)
NEXT i
GOSUB swap_para
GOSUB compute_angle
a2_start = a1
a2_end = a2
a2_start2d = a2_start * 1800 / PI
a2_end2d = a2_end * 1800 / PI
FOR i = 0 TO pt_num - 1
    a = a2_start + (a2_end - a2_start) * i / (pt_num - 1)
    dis=w/(2*COS(a))+r/COS(a)-h/(SIN(a)*COS(a))+h*COS(a)/SIN(a)
    dis2go = c2c - dis
    TABLE(table_start + pt_num + i, dis2go)
NEXT i
'table reversion
FOR i = 0 TO pt_num / 2 - 1
    temp = TABLE(table_start + pt_num + i)
    TABLE(table_start + pt_num + i, TABLE(table_start + 2 * pt_num - 1 - i))
    TABLE(table_start + 2 * pt_num - 1 - i, temp)
NEXT i
RETURN
