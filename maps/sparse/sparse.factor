! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators factorino.maps.general hash-sets kernel
math math.vectors sequences sets factorino.maps.utils factorino.maps.display.common 
assocs ;
IN: factorino.maps.sparse

<PRIVATE
PRIVATE>

TUPLE: sparse-map map size ;
M: sparse-map init 
    H{ } clone >>map swap >>size ;
M: sparse-map set-state 
    2dup in-map? [ map>> set-at ] 
    [ 3drop ] if ;
M: sparse-map neighbours 
    map>> [ side-neighbours ] dip [ at* [ (is-obstacle?) ] [ drop t ] if ] curry filter length ;
M: sparse-map state 
    2dup in-map? [
        map>> at* [ drop UNEXPLORED ] unless
    ] [
        2drop MAX-OBSTACLE
    ] if ;
M: sparse-map all-obstacles map>> [ nip (is-obstacle?) ] assoc-filter keys ;
M: sparse-map map-size size>> ;
M: sparse-map draw-map 
    all-obstacles swap [ draw-obstacle ] curry each ;

