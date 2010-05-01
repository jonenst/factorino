! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.bindings kernel models math arrays sequences 
combinators.short-circuit ;
IN: factorino.types

TUPLE: robotino com-id omnidrive-id bumper-id sensors-id odometry-id camera-id 
current-direction initial-angle 
current-position position-refresh-alarm
{ imu-angle initial: 0.0 } imu-thread
calibration-table
;
TUPLE: robotino-position-model < model ;
: throw-when-false ( return-code -- ) FALSE = [ "False return code from openrobotino1 lib" throw ] when ;

TUPLE: position {x,y} phi ;
<PRIVATE
: fix-angle ( angle -- newangle )
    360 rem dup 180 > [ 360 - ] when ;
PRIVATE>
: <position> ( {x,y} phi -- position )
    dup [ fix-angle ] when position boa ;
PREDICATE: 2d-point < sequence { 
        [ length 2 = ] 
        [ [ real? ] all? ]
    } 1&& ;
