! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators.short-circuit
factorino.basics io kernel math math.order math.vectors
prettyprint threads sequences locals math.functions ;
IN: factorino.asserv


: angular-distance ( a1 a2 -- distance )
    [ - ] [ swap - ] 2bi [ 360 rem ] bi@ min ;

CONSTANT: SPEED-MULTIPLIER 8
CONSTANT: OMEGA-MULTIPLIER 3
CONSTANT: MINIMUM-SPEED 10 ! mm/sec ??
CONSTANT: MAXIMUM-SPEED 500 ! mm/sec ??
CONSTANT: MINIMUM-ROTATION 0 ! mm/sec ??
CONSTANT: MAXIMUM-ROTATION 50 ! mm/sec ??
CONSTANT: XY-THRESHOLD 10 ! mm ??
CONSTANT: PHI-THRESHOLD 1 ! degrees
CONSTANT: OBSTACLE_THRESHOLD 0.5

: to-position-speed ( norm -- speed )
    dup 50 > [
    drop 400
    ] [
        SPEED-MULTIPLIER *
    ] if ;

: to-position-vector ( robotino position -- vector )
    swap
    [ [ {x,y}>> ] [ odometry-xy ] bi* v- ]
    [ nip odometry-phi neg ] 2bi
    rotate-degrees ;
: to-position-speed-vector ( robotino position -- speed-vector )
    to-position-vector [ normalize ] [ norm ] bi 
    dup zero? [ 2drop { 0 0 } ] [ to-position-speed v*n ] if ;

: fit-to-range ( omega -- omega )
    MAXIMUM-ROTATION [ neg ] keep clamp ;
: adjust-current ( goal current -- goal current )
    2dup > [ 360 + ] [ 360 - ] if ;
: chose-side ( goal current -- omega )
    2dup - abs 180 > [ 
    adjust-current
    ] when - ;
: to-position-omega ( robotino position -- omega )
    dup phi>> [
        [ odometry-phi ] [ phi>> ] bi* 
        swap chose-side OMEGA-MULTIPLIER * 
        fit-to-range
    ] [
        drop current-direction>> phi>>  
    ] if ;

: go-position ( robotino position -- current-dir )
    [ drop ] [ to-position-speed-vector ] [ to-position-omega ] 2tri
    [ omnidrive-set-velocity ] 2keep drop ;

: xy-at-position? ( robotino position -- ? ) 
    dup {x,y}>> [ 
        [ odometry-xy ] [ {x,y}>> ] bi* v- norm XY-THRESHOLD <
    ] [ 
        2drop t 
    ] if ;
: theta-at-position? ( robotino position -- ? )
    dup phi>> [ 
        [ odometry-phi ] [ phi>> ] bi* angular-distance PHI-THRESHOLD <
    ] [
        2drop t
    ] if ;
: at-position? ( robotino position -- ? )
    { [ xy-at-position? ] [ theta-at-position? ] } 2&& ;

: stop ( robotino -- ) { 0 0 } 0 omnidrive-set-velocity ;

: print-position ( robotino -- robotino )
    [ [ odometry-xy ] [ odometry-phi ] bi "Position : " . . . ] keep ;
:: >padding ( direction -- padding ) 
    direction norm :> r
    r zero? [ f ] [
        direction first2 :> ( x y )
        { [ y zero? ] [ x 0 < ] } 0&& [
            180
        ] [
            y x r + / atan 2 * to-degrees 
        ] if
    ] if ;
CONSTANT: FRONT-RANGE 45
: front-range ( padding -- range ) 
    FRONT-RANGE [ - ] [ + ] 2bi 2array ;
: in-range ( angle range -- ? ) 
    [ 360 [ + ] [ - ] [ drop ] 2tri ] dip
    [ first2 between? ] curry tri@ or or ;
: front-indices ( robotino range -- indices )
    [ sensors-headings ] dip 
    [ swapd in-range [ drop f ] unless ] curry map-index sift ;
: values-in-range ( robotino range -- values ) 
    dupd front-indices swap [ distance-sensor-voltage ] curry map ;
: against-obstacle? ( robotino current-direction -- ? )
    >padding dup [ front-range values-in-range
    supremum OBSTACLE_THRESHOLD > ] [ nip ] if ;
DEFER: drive-position
: continue-driving ( stop? robotino position -- blocking-pos/f )
    2dup at-position? [
        drop swap [ stop ] [ drop ] if f 
    ] [
        drive-position
    ] if ;

:: drive-position ( stop? robotino position -- blocking-pos/f )
    robotino position go-position :> current-dir
    robotino current-dir against-obstacle? [
        robotino stop position
    ] [
        robotino com-wait-for-update*
        ! WTF, com-wait-for-update* is blocking !! 
        yield
        stop? robotino position continue-driving
    ] if ;

: drive-origin ( robotino -- blocking-position/f )
    [ t ] dip T{ position f { 0 0 } 0 } drive-position ;
: drive-xy ( stop? robotino {x,y} -- blocking-position/f )
    f <position> drive-position ;

GENERIC: drive-to* ( stop? robotino destination -- blocking-position/f )
: drive-path ( stop? robotino path -- blocking-position/f )
    [ swap [ stop ] [ drop ] if f ]
    [ unclip pick swap [ f ] 2dip drive-to* [ [ 3drop ] dip ] [ drive-path ] if* ]
    if-empty ;
PREDICATE: 2d-point < array { 
        [ length 2 = ] 
        [ [ real? ] all? ]
    } 1&& ;
M: 2d-point drive-to* drive-xy ;
M: array drive-to* drive-path ;
M: position drive-to* drive-position ;

: drive-to ( robotino destination -- blocking-position/f )
    [ t ] 2dip drive-to* ;
GENERIC# change-base 1 ( destination base -- new-destinations )
M: 2d-point change-base [ nip {x,y}>> ] [ phi>> to-radian rotate ] 2bi v+ ;
M: array change-base [ change-base ] curry map ;
M: position change-base [ [ {x,y}>> ] dip change-base ] [ [ phi>> ] bi@ + ] 2bi <position> ;
! All destinations in initial base
: from-robotino-base ( robotino destination -- robotino new-destinations )
    over odometry-position change-base ;
: drive-from-here ( robotino destination -- blocking-pos/f )
    from-robotino-base drive-to ;
! All relative destinations
: drive-from-here* ( robotino destination -- blocking-pos/f )
    [ drop f ]
    [ unclip pick swap drive-from-here [ 2nip ] [ drive-from-here ] if* ] if-empty ;

