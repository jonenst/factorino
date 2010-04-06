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
:: (go-to) ( robotino position the-map -- arrived? )
    robotino set-rotating
    robotino odometry-xy position
    [ {x,y}>{i,j} ] bi@
    over :> current-position
    [ dup "I'm at : " write . ] [ dup "Going to " write . ] bi*
    ! this doesn't belong here..
    ! current-position the-map delete
    the-map <my-astar>
    ! FUCK
    "COUCOU" write yield
    find-path dup empty? not [ rest :> cell-path
    cell-path "cell path is : " write .
    the-map "Map is : " write .
    yield
    cell-path [
    cell-path [ {i,j}>{x,y} ] map :> real-path
    robotino real-path drive-to :> result 
    result [
    result {x,y}>> {x,y}>{i,j} :> obstacle
    obstacle "adding obstacle @" write . 
    obstacle the-map t set-obstacle 
robotino position the-map (go-to)
    ] [ t ] if
    ] [ f ] if ] [ drop t ] if ;
: go-to ( robotino position -- arrived? )
   { 10000 10000 } cell-size v/n \ sparse-map <map> [ display ] [ (go-to) ] bi ;
