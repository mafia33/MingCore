WHILE TRUE
    'auto mode
    begin_deg = VR(100)
    end_deg = VR(101)
    mode = VR(7)
    safe_pos = VR(211)
    corner_active = VR(175)
    cycle_start = READ_BIT(0, 12)
    bowl_start = READ_BIT(1, 12)
    reset_alarm = READ_BIT(4, 12)
    bowl_stop_delay = VR(106) 'stop bowl when it is full of materials
    bowl_start_delay = VR(107) 'start bowl when it is lack of materials
    bowl_alarm_delay = VR(108) 'report alarm when it is lack of materials

    GOSUB alarm_emerg
    GOSUB io_refresh
    GOSUB pos_refresh
    GOSUB product_count_clear

    IF cycle_start = 1 AND cycle_start_flag = 0 AND state_alarm = 0 AND state_emg = 0 THEN
        cycle_start_flag = 1
        op_mode = 1
        IF WDOG = 0 THEN
            WDOG = 1
            WA(1000)
        ENDIF
        VR(14) = 1
        OP(14, 1) 'run status, yellow light
        OP(15, 0) 'idle staus, red light
        IF mode = 1 THEN
            RUN "CIRCLE", 4
        ENDIF
        IF mode = 2 THEN
            RUN "ELLIPSE", 4
        ENDIF
        IF mode = 4 THEN
            RUN "RUNWAY", 4
            'RUN "TEST", 4
        ENDIF
        IF mode = 8 THEN
            IF corner_active = 1 THEN
                RUN "RECT_R", 4
            ELSE
                RUN "RECT", 4
            ENDIF
        ENDIF
        PSWITCH(0, OFF)
        GOSUB home
        OP(8, 1)
        OP(10, 1)
    ENDIF
    IF op_mode = 1 THEN
        OP(11, 1)
        'GOSUB bowl_auto
        IF (VR(304) = 1 OR mode = 1) AND motion_start = 0 THEN
            motion_start = 1
            BASE(2)
            SPEED = VR(105)
            ACCEL = SPEED*10
            DECEL = ACCEL
            MOVEABS(safe_pos)
            WAIT IDLE
            BASE(0)
            PSWITCH(0, ON, 0, 20, ON, begin_deg, end_deg)
            SPEED = VR(203) * 60 / 100
            ACCEL = SPEED*10
            DECEL = ACCEL
            FORWARD
            WAIT LOADED
        ENDIF
        IF IN(7) = ON THEN
            OP(12, 0)
        ELSE
            OP(12, 1)
        ENDIF
    ENDIF
    IF cycle_start = 0 AND VR(307) = 0 AND cycle_start_flag = 1 AND IN(20) = OFF THEN
        cycle_start_flag = 0
        op_mode = 0
        motion_start = 0
        VR(304) = 0
        VR(14) = 0
        OP(8, 0)
        OP(9, 0) 'blow off
        OP(10, 0)
        OP(11, 0)
        OP(12, 0) 'inhale off
        BASE(0)
        CANCEL
        IF mode = 1 THEN
            STOP "CIRCLE"
        ENDIF
        IF mode = 2 THEN
            STOP "ELLIPSE"
        ENDIF
        IF mode = 4 THEN
            STOP "RUNWAY"
            'STOP "TEST"
        ENDIF
        IF mode = 8 THEN
            IF corner_active = 1 THEN
                STOP "RECT_R"
            ELSE
                STOP "RECT"
            ENDIF
        ENDIF
    ENDIF
    IF op_mode = 0 THEN
        OP(14, 0)
        OP(15, 1)
        clamp_fo_btn = READ_BIT(4, 9)
        clamp_home_btn = READ_BIT(5, 9)
        thimble_fo_btn = READ_BIT(6, 9)
        thimble_home_btn = READ_BIT(7, 9)
        slide_fo_btn = READ_BIT(8, 9)
        slide_re_btn = READ_BIT(9, 9)
        slide_home_btn = READ_BIT(10, 9)

        grinder_btn = READ_BIT(0, 9)
        blow_btn = READ_BIT(1, 9)
        inhale_btn = READ_BIT(2, 9)
        unloader_btn = READ_BIT(3, 9)
        bowl_btn = READ_BIT(11, 9)

        JOGSPEED AXIS(0) = VR(208) / 100 * 3600 / 60
        JOGSPEED AXIS(1) = VR(209) / 100 * 3600 / 60
        JOGSPEED AXIS(2) = VR(210) * 0.1

        OP(16, thimble_fo_btn) 'thimble forward jog
        OP(17, clamp_fo_btn) 'clamp forward jog
        OP(18, slide_fo_btn) 'slide forward jog
        OP(19, slide_re_btn) 'slide reverse jog
        'Axis thimble home
        IF thimble_home_btn = 1 THEN
            GOSUB thimble_home
            CLEAR_BIT(7, 9)
        ENDIF
        'Axis clamp home
        IF clamp_home_btn = 1 THEN
            GOSUB clamp_home
            CLEAR_BIT(5, 9)
        ENDIF
        'Axis slide home
        IF slide_home_btn = 1 THEN
            GOSUB slide_home
            CLEAR_BIT(10, 9)
        ENDIF
        'grinder
        IF grinder_btn = 1 THEN
            OP(8, 1)
        ELSE
            OP(8, 0)
        ENDIF
        'air
        IF blow_btn = 1 THEN
            OP(9, 1)
        ELSE
            OP(9, 0)
        ENDIF

        IF inhale_btn = 1 THEN
            OP(12, 1)
        ELSE
            OP(12, 0)
        ENDIF
        'vibration feeder
        IF bowl_btn = 1 THEN
            OP(11, 1)
        ELSE
            OP(11, 0)
        ENDIF

        IF unloader_btn = 1 THEN
            OP(10, 1)
        ELSE
            OP(10, 0)
        ENDIF
    ENDIF

    GOSUB recipe
WEND

home:
'slide home first, then thimble and clamp
GOSUB slide_home
GOSUB thimble_home
GOSUB clamp_home
RETURN

slide_home:
BASE(2)
SPEED=200*1
'SPEED=100
INVERT_IN(4, ON)
DATUM_IN = 4 '(home switch IN 4)
'DATUM(3)
DATUM(4)
WAIT IDLE
DEFPOS(0)
WAIT UNTIL DPOS AXIS(2)=0
RETURN

thimble_home:
BASE(0)
'SPEED=3600*1
SPEED=500
INVERT_IN(3, ON)
DATUM_IN = 3 '(home switch IN 3)
DATUM(3)
WAIT IDLE
DEFPOS(0)
WAIT UNTIL DPOS AXIS(0)=0
RETURN

clamp_home:
BASE(1)
'SPEED=3600*1
SPEED=500
INVERT_IN(2, ON)
DATUM_IN = 2 '(home switch IN 2)
DATUM(4)
WAIT IDLE
DEFPOS(0)
WAIT UNTIL DPOS AXIS(1)=0
RETURN

bowl_auto:
IF IN(0) = OFF AND bowl_state = 1 THEN
    IF ticks_set_03 = 0 THEN
        ticks_set_03 = 1
        TICKS = bowl_stop_delay
    ENDIF
    IF TICKS <= 0 THEN
        ticks_set_03 = 0
        OP(11, 0)
        bowl_state = 0
    ENDIF
ENDIF
IF IN(0) = ON AND bowl_state = 0 AND VR(13).3 = 0 THEN
    IF ticks_set_04 = 0 THEN
        ticks_set_04 = 1
        TICKS = bowl_start_delay
    ENDIF
    IF TICKS <= 0 THEN
        ticks_set_04 = 0
        OP(11, 1)
        bowl_state = 1
    ENDIF
ENDIF
IF IN(0) = ON AND bowl_state = 1 THEN
    IF ticks_set_05 = 0 THEN
        ticks_set_05 = 1
        IF bowl_alarm_delay - bowl_start_delay > 0 THEN
            TICKS = bowl_alarm_delay - bowl_start_delay
        ELSE
            TICKS = bowl_alarm_delay
        ENDIF
    ENDIF
    IF TICKS <= 0 THEN
        ticks_set_05 = 0
        OP(11, 0)
        bowl_state = 0
        VR(13).3 = 1
        state_alarm = 1
        IF cycle_start = 1 THEN
            CLEAR_BIT(0, 12)
        ENDIF
    ENDIF
ENDIF
IF bowl_start = 1 AND bowl_state = 0 THEN
    OP(11, 1)
    bowl_state = 1
ENDIF
IF bowl_start = 0 AND bowl_state = 1 THEN
    OP(11, 0)
    bowl_state = 0
ENDIF
RETURN

product_count_clear:
IF VR(12).2 = 1 AND VR(12).3 = 0 THEN
    IF ticks_set_01 = 0 THEN
        ticks_set_01 = 1
        TICKS = 1000
    ENDIF
    IF TICKS <= 0 THEN
        VR(5)=0
    ENDIF
ENDIF
IF VR(12).2 = 0 THEN
    ticks_set_01 = 0
ENDIF
IF VR(12).3 = 1 AND VR(12).2 = 0 THEN
    IF ticks_set_02 = 0 THEN
        ticks_set_02 = 1
        TICKS = 1000
    ENDIF
    IF TICKS <= 0 THEN
        VR(6)=0
    ENDIF
ENDIF
IF VR(12).3 = 0 THEN
    ticks_set_02 = 0
ENDIF
RETURN

io_refresh:
i = 0
FOR i = 0 TO 15
    IF i <= 6 THEN
        VR(10).i = IN(i) 'input
    ELSEIF i = 7 THEN
        VR(10).i = WDOG
    ELSE
        VR(10).i = READ_OP(i) 'output
    ENDIF
NEXT i
RETURN

pos_refresh:
VR(200) = MPOS AXIS(0)
VR(202) = MPOS AXIS(1)
VR(201) = MPOS AXIS(2)
RETURN

alarm_emerg:
IF IN(1) = ON THEN 'emergency stop
    RAPIDSTOP
    WDOG = 0
    state_emg = 1
    IF cycle_start = 1 THEN
        CLEAR_BIT(0, 12)
        VR(307) = 0
        PSWITCH(0, OFF)
        OP(20, OFF)
    ENDIF
ELSE
    state_emg = 0
ENDIF
IF IN(5) = OFF THEN
    RAPIDSTOP
    WDOG = 0
    state_alarm = 1
    VR(13).4 = 1
    IF cycle_start = 1 THEN
        CLEAR_BIT(0, 12)
        VR(307) = 0
        PSWITCH(0, OFF)
        OP(20, OFF)
    ENDIF
ELSE
    VR(13).4 = 0
    state_alarm = 0
ENDIF
IF IN(6) = OFF THEN
    RAPIDSTOP
    WDOG = 0
    state_alarm = 1
    VR(13).5 = 1
    IF cycle_start = 1 THEN
        CLEAR_BIT(0, 12)
        VR(307) = 0
        PSWITCH(0, OFF)
        OP(20, OFF)
    ENDIF
ELSE
    VR(13).5 = 0
    state_alarm = 0
ENDIF
IF state_alarm = 1 THEN
    OP(13, 1)
ELSE
    OP(13, 0)
ENDIF
IF reset_alarm = 1 AND flag_reset = 0 THEN
    flag_reset = 1
    FOR i = 0 TO 5
        VR(13).i = 0
    NEXT i
    state_alarm = 0
    IF state_emg = 0 AND state_alarm = 0 AND WDOG = 0 THEN
        WDOG = 1
    ENDIF
ELSE
    flag_reset = 0
ENDIF
RETURN

recipe:
VR(1000)=111
VR(1002)=14
VR(1006)=14
VR(1009)=14
VR(1001)=VR(1003)*VR(1002)
VR(1004)=VR(1003)*VR(1006)
VR(1005)=111
VR(1007)=4000
VR(1008)=VR(1003)*VR(1009)

VR(1010)=131
VR(1012)=14
VR(1016)=14
VR(1019)=14
VR(1011)=VR(1013)*VR(1012)+7500
VR(1014)=VR(1013)*VR(1016)+7500
VR(1015)=131
VR(1017)=4000
VR(1018)=VR(1013)*VR(1019)+7500

VR(1020)=151
VR(1022)=14
VR(1026)=14
VR(1029)=14
VR(1021)=VR(1023)*VR(1022)+15000
VR(1024)=VR(1023)*VR(1026)+15000
VR(1025)=151
VR(1027)=4000
VR(1028)=VR(1023)*VR(1029)+15000

VR(1030)=171
VR(1032)=18
VR(1036)=18
VR(1039)=18
VR(1031)=VR(1033)*VR(1032)+22500
VR(1034)=VR(1033)*VR(1036)+22500
VR(1035)=171
VR(1037)=4000
VR(1038)=VR(1033)*VR(1039)+22500
VR(205)=INT(VR(5)/65536)
VR(204)=VR(5)-VR(205)*65536
VR(207)=INT(VR(6)/65536)
VR(206)=VR(6)-VR(207)*65536
RETURN
