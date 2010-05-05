! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs colors.constants factorino.types kernel
math math.constants math.functions math.vectors opengl
sequences ui.gadgets ui.render ;
IN: factorino.sensor-disp
CONSTANT: points-number 20

CONSTANT: circle-radius 50
CONSTANT: circle-center { 100 100 }
TUPLE: sensor-gadget < gadget robotino ;
: root-rotate-angle ( n -- angle ) 2 pi * swap / ;
: unit-roots ( n -- seq )
    [ iota ] keep 
    [ root-rotate-angle * 1 swap polar> ] curry map ;
: >2d-points ( seq -- seq )
    [ >rect 2array ] map ;
: circle-vertices ( center radius -- vertices )
   points-number unit-roots >2d-points [ n*v v+ ] with with map ; 
: gl-circle ( center radius -- )
   circle-vertices dup unclip suffix [ gl-line ] 2each ;  

M: sensor-gadget pref-dim* drop { 200 200 } ;
M: sensor-gadget draw-gadget* 
    robotino>> [ sensors-headings ] [ sensors-values ] bi zip
    [ second 1 > ] filter 
    drop
    COLOR: black gl-color
    { 100 100 } 50 gl-circle ;
