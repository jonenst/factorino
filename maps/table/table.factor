! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.maps.general sequences arrays kernel accessors 
locals math combinators.short-circuit factorino.maps.utils math.vectors
fry factorino.maps.display.common math.order ;
IN: factorino.maps.table

TUPLE: table-map table size index-offset ;
<PRIVATE
: matrix-dim ( matrix -- i j ) [ length ] [ first length ] bi ;
: set-Mi,j ( elt {i,j} matrix -- ) [ first2 swap ] dip nth set-nth ;
: Mi,j ( {i,j} matrix -- elt ) [ first2 swap ] dip nth nth ;
: mchange-nth ( {i,j} matrix quot -- ) [ [ Mi,j ] dip call ] 3keep drop set-Mi,j ; inline
: meach-index ( matrix quot -- ) 
    [ [ swap 2array ] prepose curry each-index ]
    curry each-index ; inline
: mfilter ( mat quot -- seq ) [ filter ] curry map concat ; inline
: filter-index ( seq quot -- indices ) V{ } clone [ '[ swap @ [ _ push ] [ drop ] if ] each-index ] keep ; inline
: mfilter-index ( mat quot -- indices ) [ swapd filter-index [ 2array ] with map ] curry map-index concat ; inline
: make-table ( size -- table )
    first2 [ UNEXPLORED <array> ] curry replicate ;
: ((mindex)) ( line obj seq -- index ) index [ 2array ] [ drop f ] if* ; 
:: (mindex) ( line obj seq -- index )
    seq [ f ] [
        unclip :> ( mrest mfirst )
        line obj mfirst ((mindex)) [ ] [ line 1 + obj mrest (mindex) ] if*
    ] if-empty ;
: mindex ( obj seq -- index ) [ 0 ] 2dip (mindex) ;
: real>table ( {i,j} size -- {i,j} )
   2 [ /i ] curry map v+ ; 
: table>real ( {i,j} size -- {i,j} )
   2 [ /i ] curry map v- ; 
: to-table ( {i,j} map -- {i,j} table )
    [ index-offset>> v+ ] [ nip table>> ] 2bi ;
: in-table? ( {i,j} map -- ? )
    { 
        [ drop [ 0 >= ] all? ]
        [ size>> v- [ 0 < ] all? ] 
    } 2&& ;

: table-map-neighbours ( {i,j} map -- neighbours ) 
    [ side-neighbours ] dip [ in-table? ] curry filter ;
    
PRIVATE>
M: table-map init 
    over make-table >>table
    over >>size
    swap 2 [ /i ] curry map >>index-offset ;
M:: table-map neighbours ( {i,j} the-map -- neighbours )
    {i,j} the-map to-table :> ( {i',j'} the-table )
    {i',j'} the-map table-map-neighbours 
    [ the-table Mi,j { [ FREE = ] [ UNEXPLORED = ] [ UNREACHABLE = ] [ OBSTACLE MAX-OBSTACLE between? ] } 1|| ] filter
    the-map size>> [ table>real ] curry map ;
M: table-map set-state to-table set-Mi,j ;
M: table-map state to-table Mi,j ;
M: table-map all-obstacles [ table>> [ (is-obstacle?) ] mfilter-index ] keep size>> [ table>real ] curry map ;
M: table-map map-size size>> ;
M: table-map random-unexplored [ table>> UNEXPLORED swap mindex ] keep size>> table>real ;
M:: table-map draw-map ( gadget the-map -- )
    the-map [ table>> ] [ size>> ] bi
    [
        table>real swap
        [ gadget ] dip
        draw-state
    ] curry meach-index ;


