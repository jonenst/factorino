! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.driving factorino.maps.table
factorino.maps.general kernel
factorino.driving.utils math calendar timers
factorino.maps.display ui.gadgets ;
IN: factorino.explore

DEFER: explore
<PRIVATE
: explore-and-loop ( robotino pos map -- )
    3dup (go-to) [ 2dup [ [ UNREACHABLE ] dip {x,y}>{i,j} ] dip set-state ] unless nip explore ;
PRIVATE>
: explore ( robotino map -- )
    [ random-unexplored {i,j}>{x,y} ] keep 
    over [ explore-and-loop ] [ 3drop ] if ;

CONSTANT: FIRST_TIME_DECAY_TIME 300
: init-decay ( map -- alarm )
    [ [ decay ] [ relayout-1 ] bi ] curry FIRST_TIME_DECAY_TIME OBSTACLE-INCREMENT-OFFSET / seconds every ;
: test-explore ( robotino -- map alarm )
    { 20 20 } \ table-map <map>
    [ display dup init-decay 2dup register-robotino [ explore ] keep ] dip ; 
