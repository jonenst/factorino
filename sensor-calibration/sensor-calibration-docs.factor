! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs help.markup help.syntax kernel quotations sequences ;
IN: factorino.sensor-calibration

HELP: ?assign-table
{ $values
    { "table" null } { "robotino" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: APPROACH-SPEED
{ $values
    
    { "value" null }
}
{ $description "" } ;

HELP: FACE-THRESHOLD
{ $values
    
    { "value" null }
}
{ $description "" } ;

HELP: MEASURE-SPEED
{ $values
    
    { "value" null }
}
{ $description "" } ;

HELP: SPEED
{ $values
    
    { "value" null }
}
{ $description "" } ;

HELP: WALL-FOUND
{ $values
    
    { "value" null }
}
{ $description "" } ;

HELP: angular-velocity-fix
{ $values
    { "robotino" null }
    { "angular-velocity" null }
}
{ $description "" } ;

HELP: assoc-supremum
{ $values
    { "assoc" assoc }
    { "key" null }
}
{ $description "" } ;

HELP: calibrate-sensors
{ $values
    { "robotino" null }
    { "calibrated?" null }
}
{ $description "" } ;

HELP: do-measures-at
{ $values
    { "robotino" null } { "positions" null } { "measure-quot" null }
    { "table" null }
}
{ $description "" } ;

HELP: face-flat-wall
{ $values
    { "robotino" null }
}
{ $description "" } ;

HELP: face-nonflat-wall
{ $values
    { "robotino" null }
}
{ $description "" } ;

HELP: find-flat-wall
{ $values
    { "robotino" null }
}
{ $description "" } ;

HELP: flat-wall?
{ $values
    { "robotino" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: found-wall?
{ $values
    { "robotino" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: front-rotations
{ $values
    
    { "positions" null }
}
{ $description "" } ;

HELP: front-values
{ $values
    { "sensor" null } { "robotino" null }
    { "measures" null }
}
{ $description "" } ;

HELP: go-away
{ $values
    { "robotino" null }
}
{ $description "" } ;

HELP: go-towards-wall
{ $values
    { "robotino" null } { "speed" null }
}
{ $description "" } ;

HELP: line
{ $values
    { "direction" null } { "length" null } { "step" null }
    { "positions" null }
}
{ $description "" } ;

HELP: maximize-global
{ $values
    { "sensor" null } { "robotino" null }
}
{ $description "" } ;

HELP: maximize-sensor
{ $values
    { "sensor" null } { "robotino" null }
}
{ $description "" } ;

HELP: measure-distances
{ $values
    { "wall-sensor" null } { "robotino" null }
    { "calibration-table" null }
}
{ $description "" } ;

HELP: measure-distances-at
{ $values
    { "wall-sensor" null } { "robotino" null } { "positions" null }
    { "table" null }
}
{ $description "" } ;

HELP: measure-distances-at*
{ $values
    { "wall-sensor" null } { "robotino" null } { "positions" null }
    { "table" null }
}
{ $description "" } ;

HELP: measure-distances-noface
{ $values
    { "wall-sensor" null } { "robotino" null } { "positions" null }
    { "table" null }
}
{ $description "" } ;

HELP: midpoint
{ $values
    { "seq" sequence }
    { "elem" null }
}
{ $description "" } ;

HELP: neighbour-sensors
{ $values
    { "i" null }
    { "i1" null } { "i2" null }
}
{ $description "" } ;

HELP: one-sensor-measure
{ $values
    { "wall-sensor" null }
    { "quot" quotation }
}
{ $description "" } ;

HELP: random-orientation
{ $values
    
    { "pos" null }
}
{ $description "" } ;

HELP: reasonnable-table?
{ $values
    { "table" null }
    { "?" boolean }
}
{ $description "" } ;

HELP: sensor-direction
{ $values
    { "i" null } { "robotino" null }
    { "dir" null }
}
{ $description "" } ;

HELP: touch-wall
{ $values
    { "robotino" null }
}
{ $description "" } ;

HELP: wall-direction
{ $values
    { "robotino" null }
    { "dir" null }
}
{ $description "" } ;

HELP: wall-neighbours-sensors
{ $values
    { "robotino" null }
    { "i1" null } { "i2" null }
}
{ $description "" } ;

HELP: with-wall-facing
{ $values
    { "robotino" null } { "quot" quotation }
    { "quot'" quotation }
}
{ $description "" } ;

HELP: ~
{ $values
    { "a" null } { "b" null }
    { "equal?" null }
}
{ $description "" } ;

ARTICLE: "factorino.sensor-calibration" "factorino.sensor-calibration"
{ $vocab-link "factorino.sensor-calibration" }
;

ABOUT: "factorino.sensor-calibration"
