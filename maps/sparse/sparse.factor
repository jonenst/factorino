! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators factorino.maps.general hash-sets kernel
math math.vectors sequences sets factorino.maps.utils factorino.maps.display.common ;
IN: factorino.maps.sparse

<PRIVATE
: half-offset ( obstacles size -- obstacles ) 
    2 [ /i ] curry map
    [ v- ] curry map ;
: line ( x y -- seq )
    [ iota ] dip [ 2array ] curry map ;
: 2-lines ( {x,y} -- seq )
    [ first 0 ]
    [ [ first ] [ second 1 - ] bi ] bi
    [ line ] 2bi@ append ;
: map-borders ( size -- obstacles )
    dup <reversed> [ 2-lines ] bi@ [ <reversed> ] map append ;
: offset-obstacles ( size -- obstacles )
    [ map-borders ] keep half-offset <hash-set> ;
PRIVATE>

TUPLE: sparse-map map explored size ;
M: sparse-map init 
    over offset-obstacles [ >>map ] [ clone >>explored ] bi
    swap >>size ;
M: sparse-map set-state 
rot
{ 
    { OBSTACLE [ [ map>> adjoin ] [ explored>> adjoin ] 2bi ] }
    { FREE [ [ map>> delete ] [ explored>> adjoin ] 2bi ] }
    { UNEXPLORED [ [ explored>> delete ] [ map>> delete ] 2bi ] }
} case ;
M: sparse-map neighbours 
    map>> [ side-neighbours ] dip [ in? not ] curry filter ;
M: sparse-map state 
    2dup explored>> in? [
        map>> in? OBSTACLE FREE ? 
    ] [ 2drop UNEXPLORED ] if ;
M: sparse-map all-obstacles map>> members ;
M: sparse-map map-size size>> ;
M: sparse-map draw-map 
    all-obstacles swap [ draw-obstacle ] curry each ;

