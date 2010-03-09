! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators.short-circuit kernel math
math.order math.vectors threads tinocopter.robotino ;
IN: tinocopter.robotino.asserv

TUPLE: position {x,y} phi ;

CONSTANT: SPEED-MULTIPLIER 2
CONSTANT: MINIMUM-SPEED 10
: home-speed ( norm -- speed )
    dup 100 > [
        drop 400
    ] [
        SPEED-MULTIPLIER * MINIMUM-SPEED max
    ] if ;


: (home-vector) ( robotino home -- vector ) 
    [ swap [ {x,y}>> ] [ odometry-xy ] bi* v- ]
    [ swap [ phi>> ] [ odometry-phi ] bi* - ] bi-curry bi rotate-degrees ;
: home-vector ( robotino home -- speed-vector )
    (home-vector) [ normalize ] [ norm ] bi home-speed v*n ;
: home-omega ( robotino home -- omega ) [ odometry-phi ] [ phi>> ] bi* - 5 / ;
: go-home ( robotino home -- )
    [ drop ] [ home-vector ] [ home-omega ] 2tri omnidrive-set-velocity ;
: xy-home? ( robotino home -- ? ) [ odometry-xy ] [ {x,y}>> ] bi* v- norm 1 < ;
: theta-home? ( robotino home -- ? ) [ odometry-phi ] [ phi>> ] bi* - abs 0.1 < ;
: home? ( robotino home -- ? ) { [ xy-home? ] [ theta-home? ] } 2&& ;
: stop ( robotino -- ) { 0 0 } 0 omnidrive-set-velocity ;
: drive-home ( robotino home -- )
    [ go-home ] [ 2dup home? [ drop stop ] [ 50 milliseconds sleep drive-home ] if ] 2bi ;
: drive-origin ( robotino -- )
    T{ position f { 0 0 } 0 } drive-home ;



