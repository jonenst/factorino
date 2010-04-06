! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.driving factorino.maps.sparse factorino.maps.general kernel ;
IN: factorino.explore

DEFER: explore
: next-unexplored ( map -- {i,j} ) ;
: explore-and-loop ( robotino pos map -- )
    3dup (go-to) [ nip explore ] [ 3drop ] if ;
: explore ( robotino map -- )
    [ next-unexplored ] keep 
    over [ explore-and-loop ] [ 3drop ] if ;

: test-explore ( robotino -- map )
    { 10000 10000 } \ sparse-map <map> [ explore ] keep ;
