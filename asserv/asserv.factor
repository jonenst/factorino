! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators.short-circuit kernel math
math.order math.vectors threads factorino.basics ;
IN: factorino.asserv

TUPLE: position {x,y} phi ;

CONSTANT: SPEED-MULTIPLIER 8
CONSTANT: OMEGA-MULTIPLIER 1/5
CONSTANT: MINIMUM-SPEED 10 ! mm/sec ??
CONSTANT: HOME-XY-THRESHOLD 1 ! mm ??
CONSTANT: HOME-PHI-THRESHOLD 1 ! degrees
: position-speed ( norm -- speed )
    dup 50 > [
        drop 400
    ] [
        SPEED-MULTIPLIER *
    ] if ;

: position-vector ( robotino position -- vector )
    [ swap [ {x,y}>> ] [ odometry-xy ] bi* v- ]
    [ swap [ phi>> ] [ odometry-phi ] bi* - ] bi-curry bi rotate-degrees ;
: position-speed-vector ( robotino position -- speed-vector )
    position-vector [ normalize ] [ norm ] bi position-speed v*n ;
: position-omega ( robotino position -- omega )
    [ odometry-phi ] [ phi>> ] bi* - OMEGA-MULTIPLIER * ;
: go-position ( robotino position -- )
    [ drop ] [ position-speed-vector ] [ position-omega ] 2tri omnidrive-set-velocity ;

: xy-position? ( robotino position -- ? ) [ odometry-xy ] [ {x,y}>> ] bi* v- norm 1 < ;
: theta-position? ( robotino position -- ? ) [ odometry-phi ] [ phi>> ] bi* - abs 0.1 < ;
: position? ( robotino position -- ? ) { [ xy-position? ] [ theta-position? ] } 2&& ;

: stop ( robotino -- ) { 0 0 } 0 omnidrive-set-velocity ;

: drive-position ( robotino position -- )
    [ go-position ] [ 2dup position? [ drop stop ] [ 50 milliseconds sleep drive-position ] if ] 2bi ;
: drive-origin ( robotino -- )
    T{ position f { 0 0 } 0 } drive-position ;

: drive-xy ( robotino {x,y} -- )
    over odometry-phi position boa drive-position ;


