WHILE TRUE
    begin_deg = VR(100)
    end_deg = VR(101)
    range_deg = VR(101) - VR(100)
    dif_h = VR(102)
    safe_pos = VR(211)
    mode = VR(7)

    wp_l = VR(302)
    wp_w = VR(303)

    major = VR(130)
    minor = VR(131)
    nturns = VR(132)
    offset_ang = VR(133)
    grinder_r = VR(134)
    home2c_dis = VR(135)

    c2c = home2c_dis + SQR(grinder_r * grinder_r - dif_h * dif_h)
    theta = ASIN(dif_h / (grinder_r + minor / 2))
    theta_d = theta * 1800 / PI
    dist = c2c - (grinder_r + minor / 2) * COS(theta)
    feed = major / 2 - minor / 2
    max_cut = (wp_w - minor) / 2

    IF IN(20) = ON AND flag_in_20 = 0 THEN
        flag_in_20 = 1
        'cur_speed = SPEED AXIS(0)
        cur_speed = SPEED AXIS(2)
        set_speed = (3600 * nturns / range_deg) * cur_speed * 4
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
        FOR turn = nturns - 1 TO 0 STEP -1
            cut_depth = max_cut * turn / nturns
            'BASE(2)
            BASE(0)
            SPEED=200*2
            ACCEL=SPEED*10
            DECEL=ACCEL
            MOVEABS(dist-cut_depth)
            WAIT IDLE

            'BASE(1, 2)
            BASE(1, 0)
            MOVE(3600/4, -feed+cut_depth)
            WAIT IDLE

            'BASE(1, 2)
            BASE(1, 0)
            MOVE(3600/4, feed-cut_depth)
            WAIT IDLE

            'BASE(1, 2)
            BASE(1, 0)
            MOVE(3600/4, -feed+cut_depth)
            WAIT IDLE

            'BASE(1, 2)
            BASE(1, 0)
            MOVE(3600/4, feed-cut_depth)
            WAIT IDLE
        NEXT turn
        'BASE(2)
        BASE(0)
        MOVEABS(safe_pos)
        WAIT IDLE
        BASE(1)
        MOVE(-offset_ang)
        WAIT IDLE
        start = 0
        VR(307) = 0
        VR(5)=VR(5)+1
        VR(6)=VR(5)
    ENDIF
WEND

