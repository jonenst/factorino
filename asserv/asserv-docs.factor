! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.asserv.private factorino.basics
factorino.types help.markup help.syntax kernel math sequences ;
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
    { "robotino" robotino } { "destination" { $link "destination" } }
    { "blocking-pos/f" { $or position 2d-point f } }
}
{ $description "Variant of " { $link drive-to } " that interprets all destinations in the base of the robotino at the time of the calling of this word. Compare with " { $link drive-from-here* } ". " } ;

HELP: drive-from-here*
{ $values
    { "robotino" robotino } { "destination" { $link "destination" } }
    { "blocking-pos/f" { $or position 2d-point f } }
}
{ $description "Variant of " { $link drive-from-here } " that uses the base at the time of the recursive calling of this word on " { $link position } " or " { $link 2d-point } " when destination is a sequence." } ;

HELP: drive-origin
{ $values
    { "robotino" robotino }
    { "blocking-position/f" { $or position 2d-point f } }
}
{ $description "drives back home." } ;

HELP: drive-to
{ $values
    { "robotino" robotino } { "destination" "a " { $link "destination" } }
    { "blocking-position/f" { $or position 2d-point f } }
}
{ $description "Drives to the destination in a absolute base (which can be reset with " { $link odometry-reset } "). This word blocks until destination is reached (using " { $link at-position? } "). Depending on the type of destination, the robot behaves differently."

{ $list 
{ "For a " { $link 2d-point } ", the robot turns in the direction of the destination, then drives in a straight line until the destination is reached." }
{ "For a " { $link position } ", the robot drives in a straight line while rotating and stops when the position and the angle are reached." } 
{ "For a " { $link sequence } ", the robot recursively drives to each position in the sequence." } } 


"If the robotino sees an obstacle on the way, outputs the current destination." } ;

HELP: from-robotino-base
{ $values
    { "robotino" robotino } { "destination" { $link "destination" } }
    { "robotino" robotino } { "new-destinations" "a destination" }
}
{ $description "changes the base destination to the current base." } ;

HELP: moving?
{ $values
    { "robotino" robotino }
    { "?" boolean }
}
{ $description "Tests if the robotino is moving. See " { $link MOVING-THRESHOLD } ". This word can take longer than you think to execute.." } ;

HELP: rotate-from-here
{ $values
    { "robotino" robotino } { "phi" real }
}
{ $description "Rotates the robot from the current angle. Does not check for obstacles. See also " { $link rotate-to } "." } ;

HELP: rotate-to
{ $values
    { "robotino" robotino } { "phi" real }
}
{ $description "Rotates the robot to an absolute angle. Does not check for obstacles. See also " { $link rotate-from-here } "." } ;

HELP: wait-few-updates
{ $values
    { "robotino" robotino }
}
{ $description "Blocks until a few updates of the robotino sensors have been done." } ;

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
