! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar combinators factorino.asserv
factorino.asserv.private factorino.basics factorino.types
factorino.utils factorino.wall-follower fry grouping io kernel math
math.constants math.functions math.ranges math.vectors
prettyprint random sequences threads ;
IN: factorino.sensor-calibration

CONSTANT: WALL-FOUND 0.5
CONSTANT: SPEED 200
CONSTANT: APPROACH-SPEED 60
CONSTANT: MEASURE-SPEED 100
CONSTANT: FACE-THRESHOLD 3 
: my~ ( a b -- equal? )
    - abs 0.05 < ;
: sensor-direction ( i robotino -- dir ) escape-vectors nth ;
: wall-direction ( robotino -- dir ) [ biggest-sensor ] keep sensor-direction ;
: found-wall? ( robotino -- ? )
    biggest-sensor-value dup "biggest sensor value : " write . WALL-FOUND > ;
: go-towards-wall ( robotino speed -- )
    over wall-direction n*v 0 omnidrive-set-velocity ;
: line ( direction offset length step -- positions )
     <range> [ v*n ] with map ;
: neighbour-sensors ( i -- i1 i2 )
    1 [ + ] [ - ] 2bi [ num-distance-sensors rem ] bi@ ; 
: wall-neighbours-sensors ( robotino -- i1 i2 )
    biggest-sensor neighbour-sensors ;
: angular-velocity-fix ( robotino -- angular-velocity )
    [ wall-neighbours-sensors ] keep
    [ distance-sensor-voltage ] curry bi@ - 15 * ANGULARVELOCITY * ;

: face-flat-wall ( robotino -- )
    dup angular-velocity-fix
    dup "face-flat-wall: correction " write . yield
    dup abs FACE-THRESHOLD > [
        [ [ { 0 0 } ] dip omnidrive-set-velocity ]
        [ drop 50 milliseconds sleep face-flat-wall ] 2bi
    ] [
        drop stop-robotino
    ] if ;


: do-measures-at ( robotino positions measure-quot: ( robotino position -- key value ) -- table )
    '[
        2dup drive-to [ throw ] when
        _ call( x y -- key value )
    ] with { } map>assoc ; inline
: with-wall-facing ( robotino quot -- quot' )
    swap [ face-flat-wall ] curry prepose ; inline
: one-sensor-measure ( wall-sensor -- quot: ( robotino position -- key value ) )
    '[ 
        [ [ _ ] dip
          [ wait-few-updates ]
          [ distance-sensor-voltage ] bi ] dip swap
    ] ; inline
: measure-distances-noface ( wall-sensor robotino positions -- table )
    rot one-sensor-measure do-measures-at ; inline
: measure-distances-at ( wall-sensor robotino positions -- table )
    rot one-sensor-measure [ over ] dip with-wall-facing do-measures-at ; inline


: measure-distances-at* ( wall-sensor robotino positions -- table )
    from-robotino-base measure-distances-noface ; inline
: front-rotations ( -- positions )
    -20 20 2 <range> [ { 0 0 } swap <position> ] map ;
: front-values ( sensor robotino -- measures )
    front-rotations from-robotino-base measure-distances-noface ;
: assoc-supremum ( assoc -- key )
    [ values supremum ] keep value-at ;
: maximize-global ( sensor robotino -- )
    [ front-values assoc-supremum ] keep swap drive-to . ;

: maximize-sensor ( sensor robotino -- )
   [ maximize-global ] call ; ! [ maximize-local ] bi ; 
: face-nonflat-wall ( robotino -- )
    [ biggest-sensor ] keep maximize-sensor ;
: midpoint ( seq -- elem ) [ midpoint@ ] keep nth ;
: flat-wall? ( robotino -- ? ) 
    { [ face-nonflat-wall ]
    [ biggest-sensor ]
    [ ]
    [ [ biggest-sensor ] keep sensor-direction pi 2 / rotate 0 200 20 line ] } cleave
    from-robotino-base
    [ measure-distances-noface values dup . dup first [ my~ ] curry all? ]
    [ midpoint drive-to drop ] 2bi ;
: random-orientation ( -- pos )
    { 0 0 } 90 270 [a,b] random <position> ;
: go-away ( robotino -- ) 
    [ dup wall-direction vneg 500 v*n drive-from-here
    [ "error going back" throw ] when ] [
    random-orientation drive-from-here drop ] bi ;
: find-wall ( robotino -- )
    [ SPEED go-towards-wall ]
    [ dup found-wall? [ 
        stop-robotino
    ] [
        [ wait-few-updates ] [ find-wall ] bi
    ] if ] bi ;
: find-flat-wall ( robotino -- )
    [ SPEED go-towards-wall ]
    [ dup found-wall? [ 
        dup flat-wall? [ stop-robotino ] [ [ go-away ] [ find-flat-wall ] bi ] if
    ] [
        dup wait-few-updates find-flat-wall 
    ] if ] bi ;

: touch-wall ( robotino -- )
    [ APPROACH-SPEED go-towards-wall ]
    [ [ dup moving? ] loop stop-robotino ] bi ;

: replace-with-norm ( calibration-table initial-positions -- calibration-table )
   [ [ second ] [ norm ] bi* swap 2array ] 2map ; 
    
: measure-distances ( wall-sensor robotino -- calibration-table )
    2dup sensor-direction vneg 30 400 20 line
    [ measure-distances-at* ] keep replace-with-norm ;

: reasonnable-table? ( table -- ? )
    keys [ >= ] monotonic? ;
: ?assign-table ( table robotino -- ? )
    over reasonnable-table? [ calibration-table<< t ] [ 2drop f ] if ;
: calibrate-sensors ( robotino -- calibrated? )
    { 
        [ find-wall "wall-found" print yield ]
 !       [ face-flat-wall ]
        [ biggest-sensor ]
        [ touch-wall "wall-touched" print yield ] 
        [ measure-distances "distance measured" print yield ]
        [ ?assign-table ]
    } cleave ;
