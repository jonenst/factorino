! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: math.vectors kernel sequences ;
IN: factorino.maps.utils

: side-neighbours ( {i,j} -- seq )
    { { 1 0 } { -1 0 } { 0 1 } { 0 -1 } } [ v+ ] with map ;
