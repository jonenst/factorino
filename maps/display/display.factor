! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms arrays calendar colors combinators
factorino.maps.general kernel math math.functions
math.rectangles math.vectors opengl sequences ui ui.gadgets
ui.gestures ui.render namespaces ui.tools.listener io prettyprint ;
IN: factorino.maps.display

<PRIVATE
: debug ( object -- object ) dup get-listener listener-streams [ . ] with-streams* ;
TUPLE: map-gadget < gadget map alarm zoom origin-offset in-drag-origin-offset ; 
: screen-size ( gadget -- dim ) rect-bounds nip ;
: screen-cell-size ( gadget -- dim ) [ screen-size ] [ zoom>> ] bi v* [ round >integer ] map ;
: invert-y ( {x,y} -- {x,-y} ) clone [ 1 swap [ neg ] change-nth ] keep ;
: invert-x ( {x,y} -- {x,-y} ) clone [ 0 swap [ neg ] change-nth ] keep ;
: v/i ( u v -- w ) [ /i ] 2map ;
: (map>screen) ( map-gadget {i,j} -- {i,j} ) 
    [ [ screen-cell-size ] [ screen-size 2 v/n ] bi over ] [ invert-y ] bi*
    v* v+ [ vneg 2 v/n ] dip v+ ;
: map>screen ( map-gadget {i,j} -- {i,j} )
    [ (map>screen) ] 2keep drop origin-offset>> v+ ;
: ((screen>map)) ( {i,j} -- {i,j} )
    [ dup 0 > [ 1 + 2 /i ] [ 1 - 2 /i ] if ] map ;
: (screen>map) ( map-gadget {i,j} -- {i,j} )
    [ [ screen-cell-size 2 v/n invert-y ] [ screen-size 2 v/n ] bi ] dip
    swap v- swap v/i ((screen>map)) ;
: screen>map ( map-gadget {i,j} -- {i,j} )
    over origin-offset>> v- (screen>map) ;

: mouse-pos ( gadget -- {i,j} ) dup hand-rel screen>map ;
: black ( -- color ) 0 0 0 1 <rgba> ;
: draw-obstacle ( obstacle map-gadget -- ) 
    [ swap map>screen ] keep screen-cell-size
    black gl-color gl-fill-rect ;

: full-screen-zoom ( gadget -- zoom ) 
    map>> map-size [ 1 + recip ] map ;

: <map-gadget> ( map -- gadget ) 
    map-gadget new swap >>map
    dup full-screen-zoom >>zoom
    { 0 0 } >>origin-offset
    { 0 0 } >>in-drag-origin-offset ;
M: map-gadget pref-dim* drop { 400 400 } ;

M: map-gadget draw-gadget* 
    [ map>> all-obstacles ] keep
    [ draw-obstacle ] curry each ;
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
