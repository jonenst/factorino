! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar factorino.asserv factorino.basics
factorino.wall-follower io kernel math math.vectors prettyprint
sequences threads tools.time math.ranges ;
FROM: factorino.asserv => stop ;
IN: factorino.sensor-calibration

CONSTANT: MOVING-THRESHOLD 1e-9
CONSTANT: WALL-FOUND 0.8
CONSTANT: SPEED 500
CONSTANT: FACE-THRESHOLD 0.5 
: moving? ( robotino -- ? )
    [ 
        [ odometry-xy ]
        100 milliseconds sleep
        [ com-wait-for-update* ]
        [ odometry-xy ] tri
    ] benchmark
    dup "time was : " write . 
    [ v- norm ] dip / 
    dup "observed velocity is " write . "---" print MOVING-THRESHOLD > ;

    
: wall-direction ( robotino -- dir )
    [ biggest-sensor ] [ escape-vectors ] bi nth ;
: found-wall? ( robotino -- ? )
    biggest-sensor-value dup "biggest sensor value : " write . WALL-FOUND > ;
: go-towards-wall ( robotino -- )
    dup wall-direction SPEED v*n 0 omnidrive-set-velocity ;
: find-wall ( robotino -- )
    [ go-towards-wall ]
    [ dup found-wall? [ stop ] [ 50 milliseconds sleep find-wall ] if ] bi ;

: neighbour-sensors ( i -- i1 i2 )
    1 [ + ] [ - ] 2bi [ num-distance-sensors rem ] bi@ ; 
: wall-neighbours-sensors ( robotino -- i1 i2 )
    biggest-sensor neighbour-sensors ;
: angular-velocity-fix ( robotino -- angular-velocity )
    [ wall-neighbours-sensors ] keep
    [ distance-sensor-voltage ] curry bi@ - 10 * ANGULARVELOCITY * ;
: face-wall ( robotino -- )
    dup angular-velocity-fix dup .
    dup abs FACE-THRESHOLD > [
        [ [ { 0 0 } ] dip omnidrive-set-velocity ]
        [ drop 50 milliseconds sleep face-wall ] 2bi
    ] [
        drop stop 
    ] if ;
: touch-wall ( robotino -- )
    [ go-towards-wall ]
    [ [ dup moving? ] loop stop  ] bi ;
: measure-distances ( robotino -- calibration-table )
    0 40 20 <range> 
    [
        drop dup wall-direction vneg 20 v*n dupd drive-from-here . 
        biggest-sensor-value
    ] with map ;

: calibrate-sensors ( robotino -- calibration-table )
    { 
        [ find-wall ]
        [ face-wall ]
        [ touch-wall ] 
        [ measure-distances ]
    } cleave ;
