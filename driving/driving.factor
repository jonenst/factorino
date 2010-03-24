! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors factorino.types inverse kernel math.vectors sets sequences 
math path-finding locals factorino.basics prettyprint math.functions factorino.asserv io threads ;
IN: factorino.driving

: side-neighbours ( {i,j} -- seq )
    { { 1 0 } { -1 0 } { 0 1 } { 0 -1 } } [ v+ ] with map ;
: <map> ( -- map ) HS{ } clone ;
: set-obstacle ( {i,j} map -- ) adjoin ;
: neighbours ( {i,j} map -- neighbours ) 
    [ side-neighbours ] dip [ in? not ] curry filter ;


TUPLE: driver < robotino map ;

: init-driver ( driver -- driver )
    V{ } clone >>map ;
: new-driver ( class -- driver )
    new 
    init-driver ;
: <driver> ( -- driver ) driver new-driver ;

\ v/n [ v*n ] define-inverse
: set-rotating ( robotino -- )
{ 0 0 } 50 omnidrive-set-velocity ;
CONSTANT: cell-size 100
: {x,y}>{i,j} ( {x,y} -- {i,j} )
    cell-size [ /i ] curry map ;
: {i,j}>{x,y} ( {i,j} -- {x,x} )
    cell-size [ * ] curry map ;

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
   current-position the-map delete
   the-map <my-astar>
   ! FUCK
   find-path dup empty? not [ rest :> cell-path
   cell-path "cell path is : " write .
   the-map "Map is : " write .
   yield
   cell-path [
       cell-path [ {i,j}>{x,y} ] map :> real-path
       robotino real-path gogo :> result 
       result [
          result {x,y}>> {x,y}>{i,j} :> obstacle
          obstacle "adding obstacle @" write . 
          obstacle the-map set-obstacle 
          robotino position the-map (go-to)
       ] [ t ] if
    ] [ f ] if ] [ drop t ] if ;
: go-to ( robotino position -- arrived? )
    <map> (go-to) ;
