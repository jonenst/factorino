! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs calendar combinators factorino.asserv factorino.basics
factorino.wall-follower io kernel math math.ranges math.vectors
prettyprint sequences threads tools.time math.functions ;
FROM: factorino.asserv => stop ;
IN: factorino.sensor-calibration

CONSTANT: MOVING-THRESHOLD 1e-9
CONSTANT: WALL-FOUND 0.8
CONSTANT: SPEED 500
CONSTANT: APPROACH-SPEED 30
CONSTANT: MEASURE-SPEED 100
CONSTANT: FACE-THRESHOLD 3 
: moving? ( robotino -- ? )
    [ 
        [ odometry-xy ]
        ! 100 milliseconds sleep
        [ [ com-wait-for-update* ] curry 3 swap times ]
        [ odometry-xy ] tri
    ] benchmark
    dup "time was : " write . 
    [ v- norm ] dip / 
    dup "observed velocity is " write 9 10^ * 
    . "---" print MOVING-THRESHOLD > ;

    
: wall-direction ( robotino -- dir )
    [ biggest-sensor ] [ escape-vectors ] bi nth ;
: found-wall? ( robotino -- ? )
    biggest-sensor-value dup "biggest sensor value : " write . WALL-FOUND > ;
: go-towards-wall ( robotino speed -- )
    over wall-direction n*v 0 omnidrive-set-velocity ;
: flat-wall? ( robotino -- ? ) drop t ;
: go-away ( robotino -- ) drop ;
: find-flat-wall ( robotino -- )
    [ SPEED go-towards-wall ]
    [ dup found-wall? [ 
        dup flat-wall? [ stop ] [ [ go-away ] [ find-flat-wall ] bi ] if
    ] [
        50 milliseconds sleep find-flat-wall 
    ] if ] bi ;

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
    [ APPROACH-SPEED go-towards-wall ]
    [ [ dup moving? ] loop stop  ] bi ;
: measure-distances ( wall-sensor robotino -- calibration-table )
    0 500 20 <range> 
    [
        -rot {
            [ wall-direction vneg 20 v*n ]
            ! TODO: don't accumulate errors
            [ swap drive-from-here 
                [ drop "error in calibration" throw ] when ] 
            [ face-wall ] 
            [ distance-sensor-voltage ]
        } cleave
    ] with with { } map>assoc ;

: calibrate-sensors ( robotino -- calibration-table )
    { 
        [ find-flat-wall ]
        [ face-wall ]
        [ biggest-sensor ]
        [ touch-wall ] 
        [ measure-distances ]
    } cleave ;
