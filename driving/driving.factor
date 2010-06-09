! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors factorino.asserv factorino.basics
factorino.maps.general factorino.maps.sparse factorino.types
factorino.driving.utils models
io kernel locals factorino.maps.display ui
math math.functions math.vectors path-finding prettyprint
sequences sets threads math.ranges arrays sequences.product combinators ;
FROM: factorino.maps.general => neighbours ;
IN: factorino.driving

<PRIVATE

: obstacle-weight ( state -- weight ) ;
: weight ( state -- weight )
    {
        { [ dup UNEXPLORED = ] [ drop 1 ] }
        { [ dup FREE = ] [ drop 5 ] }
        { [ dup (is-obstacle?) ] [ obstacle-weight ] }
    } cond ;
! TODO: subclass astar to use optimizing compiler
: <my-astar> ( map -- astar ) 
    [ neighbours ] 
    [ nip state weight ] bi-curry
    [ v- [ abs ] [ + ] map-reduce ]
    <astar> ;
: >real-path ( cell-path -- real-path ) [ {i,j}>{x,y} ] map ;
: >cell-path ( real-path -- cell-path ) [ {x,y}>{i,j} ] map ;
: before ( object seq -- begin/f ) [ index ] keep swap 
[ cut drop ] [ drop f ] if* ; 


: angle>pos ( angle -- pos ) 
    cell-size 1.5 * swap polar> >rect 2array ;
: angles>pos ( seq -- seq ) [ angle>pos ] map ;

: mark-state ( state seq map -- )
    [ set-state ] curry with each ;
: mark-free ( seq map -- ) [ FREE ] 2dip mark-state ;
: mark-obstacle ( seq map -- ) [ OBSTACLE ] 2dip mark-state ;
: (surrounding-positions) ( position -- positions )
    -1 1 [a,b] dup 2array [ v+ ] with product-map ;
: surrounding-positions ( robotino -- positions )
    filtered-xy {x,y}>{i,j} (surrounding-positions) ;
: register-obstacles ( map robotino -- ) 
    [ surrounding-positions swap mark-free ]
    [ dup seen-obstacles angles>pos
    from-robotino-base nip [ {x,y}>{i,j} ] map 
    swap mark-obstacle ] 2bi ;


:: explore-path ( map robotino cell-path -- free-cells obstacle/f ) 
    [ 
    ! map robotino register-obstacles
    ] robotino cell-path
    [ >real-path drive-execute-path ] keep
    over [ [ {x,y}>> {x,y}>{i,j} ] dip [ before ] 2keep drop ] [ swap ] if ;
: is-on? ( robotino cell -- ? )
    [ odometry-xy {x,y}>{i,j} ] dip = ;
: go-end ( robotino cell-path -- )
    [ drop ] [ last {i,j}>{x,y} drive-to drop ] if-empty ;
: ?go-back ( cell-path robotino obstacle -- )
    2dup is-on? [ drop swap go-end ] [ 3drop ] if ;

PRIVATE>
! FUCK
! C'est quoi ce mot ?!?!? @FUUUU
: update-current-path ( path robotino -- )
    current-path>> set-model ;
:: (go-to) ( robotino position the-map -- arrived? )
    robotino odometry-xy position
    [ {x,y}>{i,j} ] bi@
    over :> current-position
    the-map <my-astar>
    find-path :> cell-path
    yield
    cell-path robotino update-current-path
    cell-path [
        cell-path empty? [ t ] [
        cell-path unclip [ FREE ] dip the-map set-state
        :> cell-path
        the-map robotino cell-path explore-path :> ( free-cells obstacle ) 
        free-cells the-map mark-free
        obstacle [
            free-cells robotino obstacle ?go-back
            obstacle the-map t set-obstacle 
            robotino position the-map (go-to)
        ] [ t ] if ] if
    ] [ f ] if ;
: go-to ( robotino position -- arrived? )
   { 2000 2000 } cell-size v/n \ sparse-map <map> display [ nip register-robotino ] [ (go-to) ] 3bi ;
