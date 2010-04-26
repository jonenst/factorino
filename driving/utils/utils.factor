! Copyright (C) 2010 Stacky Guy.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.basics kernel sequences math ;
IN: factorino.driving.utils

CONSTANT: cell-size 100
: set-rotating ( robotino -- ) { 0 0 } 50 omnidrive-set-velocity ;
: {x,y}>{i,j} ( {x,y} -- {i,j} ) cell-size [ /i ] curry map ;
: {i,j}>{x,y} ( {i,j} -- {x,x} ) cell-size [ * ] curry map ;
