! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar colors combinators
delegate factorino.maps.display.common factorino.maps.general
io kernel math math.functions math.rectangles math.vectors
namespaces opengl prettyprint sequences ui ui.gadgets
ui.gestures ui.render ui.tools.listener threads ;
IN: factorino.maps.display

<PRIVATE
: debug ( object -- object ) dup get-listener listener-streams [ . ] with-streams* ;
: mouse-pos ( gadget -- {i,j} ) dup hand-rel screen>map ;

: full-screen-zoom ( gadget -- zoom ) 
    map-size [ recip ] map ;
: full-screen-offset ( gadget -- offset )
    [ screen-cell-size ] [ map-size ] bi
    [ odd? [ drop 0 ] [ 2 / ] if ] 2map invert-y ;
: apply-full-screen-offset ( gadget -- )
    dup full-screen-offset >>origin-offset drop ;
: draw-robotino ( gadget -- )
    [ robotino-position>> ] keep over [ ROBOTINO draw-state ] [ 2drop ] if ;
: draw-current-path ( gadget -- )
    [ current-path>> ] keep over [ [ CURRENT-PATH draw-state ] curry each ] [ 2drop ] if ;
: <map-gadget> ( map -- gadget ) 
    map-gadget new swap >>map
    dup full-screen-zoom >>zoom
    dup full-screen-offset >>origin-offset
    { 0 0 } >>in-drag-origin-offset ;
M: map-gadget pref-dim* drop { 400 400 } ;
M: map-gadget draw-gadget* 
    [ dup map>> draw-map ] [ draw-current-path ] [ draw-robotino ] tri ;
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
: update-current-path ( map path -- )
   >>current-path relayout-1 ;
: update-robotino-position ( map pos -- )
   >>robotino-position relayout-1 ;
: display ( map -- map-gadget ) <map-gadget> [ [ "Map" open-window ] curry with-ui ] keep yield dup apply-full-screen-offset ;
M: map-gadget set-state [ map>> set-state ] [ relayout-1 ] bi ;

