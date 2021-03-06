'modbus initial
ADDRESS=1
SETCOM(9600,8,1,2,2,4)
'Axis Parameters
'Axis thimble
BASE(2)
UNITS=4000*16/3600*3
ATYPE=43
'Velocity profile
CREEP=200
SPEED=500
JOGSPEED=20
ACCEL=SPEED*10
DECEL=ACCEL
'Limits
DATUM_IN=-1
'FE_LIMIT=1
FE_LIMIT=1
FHOLD_IN=-1
FS_LIMIT=100000
FWD_IN=-1
REP_DIST=3600
REP_OPTION=1
REV_IN=-1
RS_LIMIT=-100000
INVERT_IN(16, ON) 'Virtual I/Os
FWD_JOG=16
'Axis output
SERVO=0

'Axis clamp
BASE(1)
'UNITS=900*16/3600 'LS
'UNITS=10800*16/3600
'UNITS=1000*16/3600 'Fuji
UNITS=5000*16/3600 'Fuji as step+direction
ATYPE=43
'Velocity profile
CREEP=100
SPEED=500
JOGSPEED=20
ACCEL=SPEED*10
DECEL=ACCEL
'Limits
DATUM_IN=-1
FE_LIMIT=1
FHOLD_IN=-1
FS_LIMIT=3600*20
FWD_IN=-1
REP_DIST=3600
REP_OPTION=1
REV_IN=-1
RS_LIMIT=-3600*20
INVERT_IN(17, ON) 'Virtual I/Os
FWD_JOG=17
'Axis output
SERVO=0

'Axis slide
BASE(0)
'UNITS=800*16/200 'LS
'UNITS=1000*16/200 'Fuji
'UNITS=5000*16/200 'Fuji as step+direction
'ATYPE=43
UNITS=2048*4/200 'Fuji as inc
ATYPE=44
P_GAIN=6.0
VFF_GAIN=7.0
'Velocity profile
CREEP=40
SPEED=200*1
JOGSPEED=10
ACCEL=SPEED*10
DECEL=ACCEL
'Limits
DATUM_IN=-1
'FE_LIMIT=1
FE_LIMIT=1000
FHOLD_IN=-1
'FS_LIMIT=500 '+5mm
FS_LIMIT=5000000
FWD_IN=5 'Axis slide positive limit(IN 5)
REP_DIST=900
REP_OPTION=0
REV_IN=6 'Axis slide negative limit(IN 6)
'RS_LIMIT=-250 '-2.5mm
RS_LIMIT=-5000000
INVERT_IN(18, ON) 'Virtual I/Os
FWD_JOG=18
INVERT_IN(19, ON) 'Virtual I/Os
REV_JOG=19
'Axis output
SERVO=1
WDOG=ON
'materials parameter
VR(302)=294
VR(303)=250
VR(305)=1000/SERVO_PERIOD

