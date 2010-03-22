! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors factorino.types inverse kernel math.vectors sets sequences ;
IN: factorino.driving

: side-neighbours ( {i,j} -- seq )
    { { 1 0 } { -1 0 } { 0 1 } { 0 -1 } } [ v+ ] with map ;
: set-obstacle ( {i,j} map -- ) adjoin ;
: neighbours ( {i,j} map -- neighbours ) 
    [ side-neighbours ] dip [ in? not ] curry filter ;

CONSTANT: cell-size 10

TUPLE: driver < robotino map ;

: init-driver ( driver -- driver )
    V{ } clone >>map ;
: new-driver ( class -- driver )
    new 
    init-driver ;
: <driver> ( -- driver ) driver new-driver ;

\ v/n [ v*n ] define-inverse

: {x,y}>{i,j} ( {x,y} -- {i,j} )
    cell-size v/n ;
: {i,j}>{x,y} ( {x,y} -- {i,j} )
    cell-size v*n ;

    
