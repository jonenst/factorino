! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.bindings kernel ;
IN: factorino.types

TUPLE: robotino com-id omnidrive-id bumper-id sensors-id odometry-id camera-id 
current-direction initial-angle
calibration-table
;
: throw-when-false ( return-code -- ) FALSE = [ "You're fucked" throw ] when ;
