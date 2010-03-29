! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays factorino.maps.general hash-sets kernel
math math.vectors sequences sets ;
IN: factorino.maps.sparse

<PRIVATE
: half-offset ( obstacles size -- obstacles ) 
    2 [ /i ] curry map
    [ v- ] curry map ;
: side-neighbours ( {i,j} -- seq )
    { { 1 0 } { -1 0 } { 0 1 } { 0 -1 } } [ v+ ] with map ;
: line ( x y -- seq )
    [ iota ] dip [ 2array ] curry map ;
: 2-lines ( {x,y} -- seq )
    [ first 0 ]
    [ [ first ] [ second ] bi ] bi
    [ line ] 2bi@ append ;
: map-borders ( size -- obstacles )
    dup <reversed> [ 2-lines ] bi@ [ <reversed> ] map append ;
: offset-obstacles ( size -- obstacles )
    [ map-borders ] keep half-offset <hash-set> ;
PRIVATE>

TUPLE: sparse-map map size ;
M: sparse-map init 
    over offset-obstacles >>map 
    swap >>size ;
M: sparse-map set-obstacle map>> adjoin ;
M: sparse-map neighbours 
    map>> [ side-neighbours ] dip [ in? not ] curry filter ;
M: sparse-map all-obstacles map>> members ;
