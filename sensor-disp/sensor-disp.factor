! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs colors.constants factorino.types kernel
math math.constants math.functions math.vectors opengl
sequences ui.gadgets ui.render
factorino.basics factorino.utils prettyprint 
calendar alarms ;
IN: factorino.sensor-disp
CONSTANT: points-number 20

CONSTANT: circle-radius 50
CONSTANT: circle-center { 100 100 }
TUPLE: sensor-gadget < gadget robotino refresh-alarm ;
M: sensor-gadget graft*
    [ [ relayout-1 ] curry 200 milliseconds every ] keep (>>refresh-alarm) ;
M: sensor-gadget ungraft* refresh-alarm>> cancel-alarm ;
: root-rotate-angle ( n -- angle ) 2 pi * swap / ;
: angle>root ( angle -- root ) 1 swap polar> ;
: unit-roots ( n -- seq )
    [ iota ] keep 
    [ root-rotate-angle * angle>root ] curry map ;
: >2d-point ( complex -- point ) >rect 2array ;
: >2d-points ( seq -- seq ) [ >2d-point ] map ;
: circle-vertices ( center radius -- vertices )
   points-number unit-roots >2d-points [ n*v v+ ] with with map ; 
: gl-circle ( center radius -- )
   circle-vertices dup unclip suffix [ gl-line ] 2each ;  
: draw-close-walls ( gadget -- )
    robotino>> [ sensors-headings ] [ sensors-values ] bi zip
    [ dup second 1 > [
            first 90 + to-radian angle>root >2d-point circle-radius v*n
            invert-y circle-center v+ { 10 10 } gl-fill-rect 
        ] [ drop ] if ]
     each ;
: draw-circle ( -- )
    circle-center circle-radius gl-circle ;
: draw-front ( -- )
    { 
        { { 100 60 } { 100 30 } }
        { { 110 40 } { 100 30 } }
        { { 90 40  } { 100 30 } } 
    } [ first2 gl-line ] each ;
M: sensor-gadget pref-dim* drop { 200 200 } ;
M: sensor-gadget draw-gadget* 
    COLOR: red gl-color draw-close-walls
    COLOR: black gl-color draw-circle
    COLOR: orange gl-color draw-front ;


: <sensor-gadget> ( robotino -- gadget )
    sensor-gadget new swap >>robotino ;
