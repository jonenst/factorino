! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.bindings kernel models ;
IN: factorino.types

TUPLE: robotino com-id omnidrive-id bumper-id sensors-id odometry-id camera-id 
current-direction initial-angle 
current-position position-refresh-alarm
calibration-table
;
TUPLE: robotino-position-model < model ;
: throw-when-false ( return-code -- ) FALSE = [ "You're fucked" throw ] when ;
