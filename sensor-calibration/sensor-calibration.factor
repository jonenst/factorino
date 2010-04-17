! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs calendar combinators factorino.asserv factorino.basics
factorino.wall-follower io kernel math math.ranges math.vectors
prettyprint sequences threads tools.time math.functions math.constants 
random ;
FROM: factorino.asserv => stop ;
IN: factorino.sensor-calibration

CONSTANT: MOVING-THRESHOLD 1e-9
CONSTANT: WALL-FOUND 0.8
CONSTANT: SPEED 500
CONSTANT: APPROACH-SPEED 30
CONSTANT: MEASURE-SPEED 100
CONSTANT: FACE-THRESHOLD 3 
: ~ ( a b -- equal? )
    - abs 0.1 < ;
: wait-few-updates ( robotino -- )
    [ com-wait-for-update* ] curry 5 swap times ;
: moving? ( robotino -- ? )
    [ 
        [ odometry-xy ]
        ! 100 milliseconds sleep
        [ wait-few-updates ]
        [ odometry-xy ] tri
    ] benchmark
    dup "time was : " write . yield
    [ v- norm ] dip / 
    dup "observed velocity is " write 9 10^ * 
    . "---" print 
    drop f ;
    ! MOVING-THRESHOLD > ;
: sensor-direction ( i robotino -- dir ) escape-vectors nth ;
: wall-direction ( robotino -- dir ) [ biggest-sensor-value ] keep sensor-direction ;
: found-wall? ( robotino -- ? )
    biggest-sensor-value dup "biggest sensor value : " write . WALL-FOUND > ;
: go-towards-wall ( robotino speed -- )
    over wall-direction n*v 0 omnidrive-set-velocity ;
: line ( direction length step -- positions )
    [ 0 ] 2dip <range> [ v*n ] with map rest ;
: neighbour-sensors ( i -- i1 i2 )
    1 [ + ] [ - ] 2bi [ num-distance-sensors rem ] bi@ ; 
: wall-neighbours-sensors ( robotino -- i1 i2 )
    biggest-sensor neighbour-sensors ;
: angular-velocity-fix ( robotino -- angular-velocity )
    [ wall-neighbours-sensors ] keep
    [ distance-sensor-voltage ] curry bi@ - 10 * ANGULARVELOCITY * ;

: face-wall ( robotino -- )
    dup angular-velocity-fix
    dup abs FACE-THRESHOLD > [
        [ [ { 0 0 } ] dip omnidrive-set-velocity ]
        [ drop 50 milliseconds sleep face-wall ] 2bi
    ] [
        drop stop 
    ] if ;
: measure-distances-at ( wall-sensor robotino positions -- table )
    [
        2dup drive-to [ "error" throw ] when
        over face-wall
        [ dup wait-few-updates distance-sensor-voltage ] dip swap
    ] with with { } map>assoc ;
: measure-distances-at* ( wall-sensor robotino positions -- table )
    from-robotino-base measure-distances-at ;

: midpoint ( seq -- elem ) [ midpoint@ ] keep nth ;
: flat-wall? ( robotino -- ? ) 
    [ biggest-sensor ]
    [ ]
    [ [ biggest-sensor ] keep sensor-direction pi 2 / rotate 200 20 line ] tri
    from-robotino-base
    [ measure-distances-at values dup . dup first [ ~ ] curry all? ]
    [ midpoint drive-to drop ] 2bi ;
: random-orientation ( -- pos )
    { 0 0 } 90 270 [a,b] random <position> ;
: go-away ( robotino -- ) 
    [ dup wall-direction vneg 100 v*n drive-from-here
    [ "error going back" throw ] when ] [
    random-orientation drive-from-here drop ] bi ;
: find-flat-wall ( robotino -- )
    [ SPEED go-towards-wall ]
    [ dup found-wall? [ 
        dup flat-wall? [ stop ] [ [ go-away ] [ find-flat-wall ] bi ] if
    ] [
        50 milliseconds sleep find-flat-wall 
    ] if ] bi ;

: touch-wall ( robotino -- )
    [ APPROACH-SPEED go-towards-wall ]
    [ [ dup moving? ] loop stop  ] bi ;

: measure-distances ( wall-sensor robotino -- calibration-table )
    2dup sensor-direction vneg 400 20 line
    measure-distances-at* ;

: calibrate-sensors ( robotino -- calibration-table )
    { 
        [ find-flat-wall ]
        [ face-wall ]
        [ biggest-sensor ]
        [ touch-wall ] 
        [ measure-distances ]
    } cleave ;
