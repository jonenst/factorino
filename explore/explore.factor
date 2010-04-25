! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.driving factorino.maps.table factorino.maps.general kernel
factorino.maps.display ;
IN: factorino.explore

DEFER: explore
: explore-and-loop ( robotino pos map -- )
    3dup (go-to) [ 2dup [ [ UNREACHABLE ] dip {x,y}>{i,j} ] dip set-state ] unless nip explore ;
: explore ( robotino map -- )
    [ random-unexplored {i,j}>{x,y} ] keep 
    over [ explore-and-loop ] [ 3drop ] if ;

: test-explore ( robotino -- map )
    { 20 20 } \ table-map <map> display [ explore ] keep ;
