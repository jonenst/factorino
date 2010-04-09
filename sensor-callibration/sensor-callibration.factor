! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: factorino.sensor-callibration

CONSTANT: MOVING-THRESHOLD 10
: moving? ( robotino -- ? )
    [ odometry-xy ]
    [ com-wait-for-update* ]
    [ odometry-xy ] v- norm MOVING-THRESHOLD > ;
    
