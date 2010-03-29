! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors factorino.maps.general inverse
kernel math math.vectors opengl sequences ui.gadgets ui.render calendar alarms ;
IN: factorino.maps.display

CONSTANT: screen-size { 400 400 }
CONSTANT: screen-cell-size { 5 5 }
: map>screen ( {i,j} -- {i,j} ) 
    screen-size 2 v/n [ 
        [ first ] bi@ +
    ] [
        [ second ] bi@ swap -
    ] 2bi 2array ;
: screen>map ( {i,j} -- {i,j} )
    screen-size 2 v/n [
        [ first ] bi@ -
    ] [
        [ second ] bi@ swap -
    ] 2bi 2array ;

: black ( -- color ) 0 0 0 1 <rgba> ;
: draw-obstacle ( obstacle -- ) 
    map>screen screen-cell-size
    black gl-color gl-fill-rect ;


TUPLE: map-gadget < gadget map alarm ; 
: <map-gadget> ( map -- gadget ) map-gadget new swap >>map ;
M: map-gadget pref-dim* drop { 400 400 } ;

M: map-gadget draw-gadget* map>> all-obstacles [ draw-obstacle ] each ;
M: map-gadget graft* dup [ relayout-1 ] curry 100 milliseconds every >>alarm drop ;
M: map-gadget ungraft* alarm>> cancel-alarm ;
    

