! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar colors combinators
factorino.maps.general factorino.maps.display.common kernel math math.functions
math.rectangles math.vectors opengl sequences ui ui.gadgets
ui.gestures ui.render namespaces ui.tools.listener io prettyprint ;
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
M: map-gadget graft* dup [ relayout-1 ] curry 200 milliseconds every >>alarm drop ;
M: map-gadget ungraft* alarm>> cancel-alarm ;
: zoom-multiplier ( dir -- multiplier )
{ { -1 [ 1.1 ] }
  { 1  [ 1.1 recip ] }
} case ;
map-gadget H{
    { T{ button-down f f 1 } [ [ mouse-pos ] [ map>> ] bi toggle-obstacle ] } 
    { T{ button-up f f 3 } [ dup origin-offset>> >>in-drag-origin-offset drop ] } 
    { T{ drag f 3 } [ dup in-drag-origin-offset>> drag-loc v+ >>origin-offset drop ] }
    { mouse-scroll [ scroll-direction get second zoom-multiplier [ v*n ] curry change-zoom drop ] }
    } set-gestures
PRIVATE>

: display ( map -- ) [ <map-gadget> "Map" open-window ] curry with-ui ;
