! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: classes factorino.types help.markup help.syntax kernel
math sequences strings ui.gadgets.buttons ;
IN: factorino.basics

HELP: <button-robotino>
{ $values
    
    { "robotino" robotino }
}
{ $description "" } ;

HELP: <init-robotino>
{ $values
    
    { "robotino" robotino }
}
{ $description "" } ;

HELP: <robotino>
{ $values
    { "address" string }
    { "robotino" robotino }
}
{ $description "" } ;

HELP: distance-sensor-heading
{ $values
    { "#" integer } { "robotino" robotino }
    { "value" real }
}
{ $description "" } ;

HELP: distance-sensor-voltage
{ $values
    { "#" integer } { "robotino" robotino }
    { "value" real }
}
{ $description "" } ;

HELP: drive
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: filtered-phi
{ $values
    { "robotino" robotino }
    { "phi" real }
}
{ $description "" } ;

HELP: filtered-position
{ $values
    { "robotino" robotino }
    { "phi" "a " { $link position } }
}
{ $description "" } ;

HELP: filtered-xy
{ $values
    { "robotino" robotino }
    { "phi" { "a pair of" { $link integer } } }
}
{ $description "" } ;

HELP: imu-port
{ $values
    
    { "value" integer }
}
{ $description "" } ;

HELP: init-imu-refresh
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: init-position-refresh
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: init-refresh-speed
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: kill-button
{ $values
    { "robotino" robotino }
    { "button" button }
}
{ $description "" } ;

HELP: kill-robotino
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: kill-window
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: new-robotino
{ $values
    { "address" string } { "class" class }
    { "robotino" robotino }
}
{ $description "" } ;

HELP: num-distance-sensors
{ $values
    
    { "n" integer }
}
{ $description "" } ;

HELP: odometry-phi
{ $values
    { "robotino" robotino }
    { "phi" real }
}
{ $description "" } ;

HELP: odometry-position
{ $values
    { "robotino" robotino }
    { "position" { "a " { $link position } } }
}
{ $description "" } ;

HELP: odometry-reset
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: odometry-set
{ $values
    { "robotino" robotino } { "position" null }
}
{ $description "" } ;

HELP: odometry-set-phi
{ $values
    { "robotino" robotino } { "phi" null }
}
{ $description "" } ;

HELP: odometry-x
{ $values
    { "robotino" robotino }
    { "x" null }
}
{ $description "" } ;

HELP: odometry-xy
{ $values
    { "robotino" robotino }
    { "{x,y}" null }
}
{ $description "" } ;

HELP: odometry-y
{ $values
    { "robotino" robotino }
    { "y" null }
}
{ $description "" } ;

HELP: omnidrive-set-velocity
{ $values
    { "robotino" robotino } { "v" null } { "omega" null }
}
{ $description "" } ;

HELP: refresh-position
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: register-camera-observer
{ $values
    { "observer" null } { "robotino" robotino }
}
{ $description "" } ;

HELP: robotino-test
{ $values
    { "adress" null }
}
{ $description "" } ;

HELP: sensors-distances
{ $values
    { "robotino" robotino }
    { "distances" null }
}
{ $description "" } ;

HELP: sensors-headings
{ $values
    { "robotino" robotino }
    { "values" sequence }
}
{ $description "" } ;

HELP: sensors-values
{ $values
    { "robotino" robotino }
    { "values" sequence }
}
{ $description "" } ;

HELP: stop-imu-refresh
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: stop-position-refresh
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: stop-refresh-speed
{ $values
    { "robotino" robotino }
}
{ $description "" } ;

HELP: unregister-camera-observer
{ $values
    { "observer" object } { "robotino" robotino }
}
{ $description "" } ;

HELP: voltage>distance
{ $values
    { "calibration-table" "a calibration table" } { "voltage" real }
    { "distance" real }
}
{ $description "" } ;

ARTICLE: "factorino.basics" "factorino.basics"
"The " { $vocab-link "factorino.basics" } " is a factor look-and-feel wrapper for the lower C functions."
;

ABOUT: "factorino.basics"
