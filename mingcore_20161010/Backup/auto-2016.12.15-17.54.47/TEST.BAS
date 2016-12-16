'test: pulse frequency and pusle number
WHILE TRUE
    IF init_axis_pa = 0 THEN
        init_axis_pa = 1

        'user parameter set
        axis_no = 2
        IF axis_no = 1 THEN
            unit = 3600
        ENDIF
        IF axis_no = 2 THEN
            unit = 200
        ENDIF
        dist_nturns = 4 'slide
        'dist_nturns = 10 'clamp
        speed_nturns = 50
        turn_pulse = 10000
        wait_time = 5000

        'axis parameter set
        BASE(axis_no)
        UNITS = turn_pulse * 16 / unit
        IF axis_no = 2 THEN
            FS_LIMIT=1000.1
            RS_LIMIT=-1000.1
            REP_DIST=1000
            REP_OPTION=0
        ENDIF
        SPEED = unit * speed_nturns
        ACCEL = SPEED * 6
        DECEL = ACCEL

        'watch
        pulse_num = dist_nturns * turn_pulse
        pulse_freq = speed_nturns * turn_pulse
        PRINT "pulse_num="; pulse_num
        PRINT "pulse_freq="; pulse_freq
    ENDIF
    IF init_axis_pa = 1 THEN
        MOVE(unit * dist_nturns)
        WA(wait_time)
        MOVE(-unit * dist_nturns)
        WA(wait_time)
    ENDIF
WEND

