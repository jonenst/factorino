! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar colors combinators
delegate factorino.maps.display.common factorino.maps.general
io kernel math math.functions math.rectangles math.vectors
namespaces opengl prettyprint sequences ui ui.gadgets
ui.gestures ui.render ui.tools.listener ;
IN: factorino.maps.display

<PRIVATE
: debug ( object -- object ) dup get-listener listener-streams [ . ] with-streams* ;
: mouse-pos ( gadget -- {i,j} ) dup hand-rel screen>map ;

: full-screen-zoom ( gadget -- zoom ) 
    map>> map-size [ 1 + recip ] map ;

: <map-gadget> ( map -- gadget ) 
    map-gadget new swap >>map
    dup full-screen-zoom >>zoom
    { 0 0 } >>origin-offset
    { 0 0 } >>in-drag-origin-offset ;
M: map-gadget pref-dim* drop { 400 400 } ;

M: map-gadget draw-gadget* dup map>> draw-map ;
: zoom-multiplier ( dir -- multiplier )
{ { -1 [ 1.1 ] }
  { 1  [ 1.1 recip ] }
} case ;
map-gadget H{
    { T{ button-down f f 1 } [ [ mouse-pos ] [ toggle-obstacle ] bi ] } 
    { T{ button-up f f 3 } [ dup origin-offset>> >>in-drag-origin-offset relayout-1 ] } 
    { T{ drag f 3 } [ dup in-drag-origin-offset>> drag-loc v+ >>origin-offset relayout-1 ] }
    { mouse-scroll [ scroll-direction get second zoom-multiplier [ v*n ] curry change-zoom relayout-1 ] }
} set-gestures

PROTOCOL: just-delegate init neighbours state all-obstacles map-size random-unexplored ;
CONSULT: just-delegate map-gadget map>> ;
PRIVATE>
: display ( map -- map-gadget ) <map-gadget> [ [ "Map" open-window ] curry with-ui ] keep ;
M: map-gadget set-state [ map>> set-state ] [ relayout-1 ] bi ;

