! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel factorino.types ;
IN: factorino.asserv

HELP: MAXIMUM-ROTATION
{ $values
    
    { "value" "a real" }
}
{ $description "The maximum rotation speed in degrees per second." } ;

HELP: MAXIMUM-SPEED
{ $values
    
    { "value" "a real" }
}
{ $description "The maximum translation speed in mm per second." } ;

HELP: MINIMUM-SPEED
{ $values
    
    { "value" "a real" }
}
{ $description "The minimum translation speed in mm per second." } ;

HELP: MOVING-THRESHOLD
{ $values
    
    { "value" "a real" }
}
{ $description "The speed under which the robot is considered not moving in 10^-9 mm per second." } ;

HELP: OBSTACLE_THRESHOLD
{ $values
    
    { "value" "a real" }
}
{ $description "The value over which we see an obstacle. There is no unit, use value>distance to have distances."  } ;

HELP: OMEGA-MULTIPLIER
{ $values
    
    { "value" "a real" }
}
{ $description "A coefficent used for control." } ;

HELP: PHI-THRESHOLD
{ $values
    
    { "value" "a real" }
}
{ $description "The robot is considered at the good angle if the difference between destination angle and current angle is less than this value in degrees." } ;

HELP: SPEED-MULTIPLIER
{ $values
    
    { "value" "a real" }
}
{ $description "A coefficent used for control." } ;

HELP: STOP-SPEED
{ $values
    
    { "value" "a real" }
}
{ $description "If activated, the robot must be slower than this value to consider that it arrived at destination." } ;

HELP: XY-THRESHOLD
{ $values
    
    { "value" "a real" }
}
{ $description "The robot is considered arrived at destination if the distance between the current position and the destination is smaller than this value." } ;

HELP: drive-from-here
{ $values
    { "robotino" robotino } { "destination" "a destination" }
    { "blocking-pos/f" "a position" }
}
{ $description "blocks until destination is reached. Destination is specified in the base relative to the robotino." } ;

HELP: drive-from-here*
{ $values
    { "robotino" robotino } { "destination" "a destination" }
    { "blocking-pos/f" "a destination or " { $instance f } }
}
{ $description "Blocks until destination is reached. If destination is an array of destinations, use a new relative base at the time the destination is considered." } ;

HELP: drive-origin
{ $values
    { "robotino" robotino }
    { "blocking-position/f" "a destination or " { $instance f } }
}
{ $description "drives back home." } ;

HELP: drive-to
{ $values
    { "robotino" robotino } { "destination" "a " { $link "destination" } }
    { "blocking-position/f" { $or position 2d-point f } }
}
{ $description "Drives to the destination in a absolute base (which can be reset with " { $link odometry-reset } "). This word blocks until destination is reached ( using" { $link at-position? } ") . If an obstacle is reached on the way, outputs the current destination." } ;

HELP: from-robotino-base
{ $values
    { "robotino" robotino } { "destination" "a destination" }
    { "robotino" robotino } { "new-destinations" "a destination" }
}
{ $description "changes the base destination to the current base." } ;

HELP: moving?
{ $values
    { "robotino" robotino }
    { "?" boolean }
}
{ $description "Tests if the robotino is moving. See MOVING-THRESHOLD." } ;

HELP: rotate-from-here
{ $values
    { "robotino" robotino } { "phi" null }
}
{ $description "Rotates the robot from the current angle. No checks are performed compared to drive-from-here." } ;

HELP: rotate-to
{ $values
    { "robotino" robotino } { "phi" null }
}
{ $description "Rotates the robot to an absolute angle." } ;

HELP: wait-few-updates
{ $values
    { "robotino" robotino }
}
{ $description "blocks until a few updates of the robotino sensors have been done." } ;

ARTICLE: "factorino.asserv" "factorino.asserv"
"The " { $vocab-link "factorino.asserv" } " vocabulary provides simple control words to move the robotino to a destination. Most words will stop if the robotino sees an obstacle."
{ $subsections
    drive-to
    drive-from-here
    drive-from-here*
}
    "The following words do not check if there are obstacles"
{ $subsections 
    rotate-to
    rotate-from-here
}
{ $subsections
    moving? wait-few-updates 
}
;

ABOUT: "factorino.asserv"
