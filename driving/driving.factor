! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors factorino.asserv factorino.basics
factorino.maps.general factorino.maps.sparse factorino.types inverse
io kernel locals factorino.maps.display ui
math math.functions math.vectors path-finding prettyprint
sequences sets threads ;
FROM: factorino.maps.general => neighbours ;
IN: factorino.driving

CONSTANT: cell-size 100
: set-rotating ( robotino -- ) { 0 0 } 50 omnidrive-set-velocity ;
: {x,y}>{i,j} ( {x,y} -- {i,j} ) cell-size [ /i ] curry map ;
: {i,j}>{x,y} ( {i,j} -- {x,x} ) cell-size [ * ] curry map ;

! TODO: subclass astar to use optimizing compiler
: <my-astar> ( map -- astar ) 
    [ neighbours ] curry
    [ 2drop 1 ]
    [ v- [ abs ] [ + ] map-reduce ]
    <astar> ;
: >real-path ( cell-path -- real-path ) [ {i,j}>{x,y} ] map ;
: >cell-path ( real-path -- cell-path ) [ {x,y}>{i,j} ] map ;
: before ( object seq -- begin/f ) [ index ] keep swap 
[ cut drop ] [ drop f ] if* ; 
: explore-path ( robotino cell-path -- free-cells obstacle/f ) 
    [ >real-path drive-to ] keep
    over [ [ {x,y}>> {x,y}>{i,j} ] dip [ before ] 2keep drop ] [ swap ] if ;
: mark-free ( seq map -- )
    [ [ FREE ] 2dip set-state ] curry each ;
: is-on? ( robotino cell -- ? )
    [ odometry-xy {x,y}>{i,j} ] dip = ;
: go-back-when-obstacle ( robotino cell-path obstacle -- )
    over index swap nth drive-to drop ; 
! TODO GO back the whole way if we have to !
: ?go-back ( cell-path robotino obstacle -- )
    2dup is-on? [ swapd go-back-when-obstacle ] [ 3drop ] if ;
    
! FUCK
! C'est quoi ce mot ?!?!? @FUUUU
:: (go-to) ( robotino position the-map -- arrived? )
  !  robotino set-rotating
    robotino odometry-xy position
    [ {x,y}>{i,j} ] bi@
    over :> current-position
    [ dup "I'm at : " write . ] [ dup "Going to " write . ] bi*
    the-map <my-astar>
    "COUCOU" write yield
    find-path :> cell-path
    cell-path "cell path is : " write .
    the-map "Map is : " write .
    yield
    ! TODO: the next 2 lines forces to use a map-gadget map.
    the-map cell-path update-current-path
    the-map current-position update-robotino-position
    cell-path [
        robotino cell-path explore-path :> ( free-cells obstacle ) 
        free-cells the-map mark-free
        obstacle [
            cell-path robotino obstacle ?go-back
            obstacle "adding obstacle @" write . yield
            obstacle the-map t set-obstacle 
            robotino position the-map (go-to)
        ] [ t ] if
    ] [ f ] if ;
: go-to ( robotino position -- arrived? )
   { 10000 10000 } cell-size v/n \ sparse-map <map> display (go-to)  ;
