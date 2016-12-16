WHILE TRUE
    begin_deg = VR(100)
    end_deg = VR(101)
    range_deg = VR(101) - VR(100)
    safe_pos = VR(211)

    wp_l = VR(302)
    wp_w = VR(303)

    cir_d = VR(110)
    nturns = VR(111)
    grinder_r = VR(112)
    home2c_dis = VR(113)
    max_cut = wp_w - cir_d / 2
    dest = home2c_dis - cir_d / 2

    IF IN(20) = ON AND flag_in_20 = 0 THEN
        flag_in_20 = 1
        cur_speed = SPEED AXIS(0)
        set_speed = (3600 * (nturns + 2) / range_deg) * cur_speed * 1.8
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
        FOR turn = nturns - 1 TO 0 STEP -1
            cut_depth = max_cut * turn / nturns
            BASE(1, 2)
            MOVEABS(3600, dest - cut_depth)
            WAIT IDLE
            BASE(1)
            DEFPOS(0)
            WAIT UNTIL DPOS AXIS(1)=0
        NEXT turn
        BASE(1, 2)
        MOVEABS(3600, dest)
        WAIT IDLE

        BASE(1)
        DEFPOS(0)
        WAIT UNTIL DPOS AXIS(1)=0

        BASE(1, 2)
        MOVEABS(3600, safe_pos)
        WAIT IDLE

        BASE(1)
        DEFPOS(0)
        WAIT UNTIL DPOS AXIS(1)=0
        start = 0
        VR(307) = 0
        VR(5) = VR(5) + 1
    ENDIF
WEND
