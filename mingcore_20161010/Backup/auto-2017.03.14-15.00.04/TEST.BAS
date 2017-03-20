'test: pulse frequency and pusle number
WHILE TRUE
    IF init_axis_pa = 0 THEN
        init_axis_pa = 1

        'user parameter set
        axis_index = 0

        'axis 0 as inc
        IF axis_index = 0 THEN
            unit = 200
            turn_pulse = 2048 / 4
            dist_nturns = 4
        ENDIF

        IF axis_index = 1 THEN
            unit = 3600
            dist_nturns = 10
            'turn_pulse = 900 'LS
            turn_pulse = 1000
        ENDIF
        IF axis_index = 2 THEN
            unit = 200
            dist_nturns = 4
            'turn_pulse = 800 'LS
            turn_pulse = 1000
        ENDIF
        speed_nturns = 50
        'speed_nturns = 50
        wait_time = 500

        'axis parameter set
        BASE(axis_index)
        UNITS = turn_pulse * 16 / unit
        IF axis_index = 2 THEN
            FS_LIMIT=1000.1
            RS_LIMIT=-1000.1
            REP_DIST=1000
            REP_OPTION=0
        ENDIF
        SPEED = unit * speed_nturns
        ACCEL = SPEED * 10
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

