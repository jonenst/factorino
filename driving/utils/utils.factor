! Copyright (C) 2010 Stacky Guy.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.basics kernel sequences math ;
IN: factorino.driving.utils

CONSTANT: cell-size 100
: set-rotating ( robotino -- ) { 0 0 } 50 omnidrive-set-velocity ;
: x>i ( x -- i ) [ abs cell-size 2 / + cell-size /i ] [ 0 < [ neg ] when ] bi ;
: i>x ( i -- x ) cell-size * ;
: {x,y}>{i,j} ( {x,y} -- {i,j} ) [ x>i ] map ;
: {i,j}>{x,y} ( {i,j} -- {x,x} ) [ i>x ] map ;
