! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators.short-circuit kernel math
math.order math.vectors threads factorino.basics prettyprint io ;
IN: factorino.asserv

TUPLE: position {x,y} phi ;

: fix-angle ( angle -- newangle )
    360 rem dup 180 > [ 360 - ] when ;
: angular-distance ( a1 a2 -- distance )
    [ - ] [ swap - ] 2bi [ 360 rem ] bi@ min ;
: <position> ( {x,y} phi -- position )
    fix-angle position boa ;

CONSTANT: SPEED-MULTIPLIER 8
CONSTANT: OMEGA-MULTIPLIER 3
CONSTANT: MINIMUM-SPEED 10 ! mm/sec ??
CONSTANT: MAXIMUM-SPEED 500 ! mm/sec ??
CONSTANT: MINIMUM-ROTATION 0 ! mm/sec ??
CONSTANT: MAXIMUM-ROTATION 50 ! mm/sec ??
CONSTANT: XY-THRESHOLD 10 ! mm ??
CONSTANT: PHI-THRESHOLD 1 ! degrees
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
    "DEBUG: position-vector : " write 2dup . . 
    rotate-degrees ;
: to-position-speed-vector ( robotino position -- speed-vector )
    to-position-vector [ normalize ] [ norm ] bi to-position-speed v*n ;

: fit-to-range ( omega -- omega )
    MAXIMUM-ROTATION [ neg ] keep clamp ;
: adjust-current ( goal current -- goal current )
    2dup > [ 360 + ] [ 360 - ] if ;
: chose-side ( goal current -- omega )
    2dup - 180 > [ 
        adjust-current
    ] when - ;
: to-position-omega ( robotino position -- omega )
    [ odometry-phi ] [ phi>> ] bi* swap
    chose-side
    OMEGA-MULTIPLIER * 
    fit-to-range ;
    
: go-position ( robotino position -- )
    [ drop ] [ to-position-speed-vector ] [ to-position-omega ] 2tri omnidrive-set-velocity ;

: xy-at-position? ( robotino position -- ? ) 
    [ odometry-xy ] [ {x,y}>> ] bi* v- norm XY-THRESHOLD < ;
: theta-at-position? ( robotino position -- ? )
    [ odometry-phi ] [ phi>> ] bi* angular-distance PHI-THRESHOLD < ;
: at-position? ( robotino position -- ? )
{ [ xy-at-position? ] [ theta-at-position? ] } 2&& ;
! 2drop t ;

: stop ( robotino -- ) { 0 0 } 0 omnidrive-set-velocity ;

: print-position ( robotino -- robotino )
    [ [ odometry-xy ] [ odometry-phi ] bi "Position : " . . . ] keep ;
: drive-position ( robotino position -- )
    [ go-position ] 
    [ 
        ! 50 milliseconds sleep
        over com-wait-for-update*
        yield
        2dup at-position? [
            drop stop
            ] [
            drive-position 
        ] if
    ] 2bi ;
: drive-origin ( robotino -- )
    T{ position f { 0 0 } 0 } drive-position ;
: drive-xy ( robotino {x,y} -- )
    over odometry-phi <position> drive-position ;




