! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors
kernel opengl sequences ui.render ui.gadgets grouping ui math calendar threads 
alarms ui.gestures factorino.basics ;
IN: factorino.camera

TUPLE: camera-gadget < gadget robotino image { on? initial: f } update-thread ;
: draw-pixel ( pixel y x -- )
    [ [ 255 / ] { } map-as first3 1 <rgba> gl-color ] 2dip 
    swap 2array { 1 1 } gl-rect ;
: draw-line ( line # -- )
    [ draw-pixel ] curry each-index ;
: raw>image ( raw -- image ) 3 group 320 group ;
: <camera-gadget> ( robotino -- gadget )
    camera-gadget new swap >>robotino ;
: update-image ( camera-gadget -- )
    dup on?>> [
    dup 
    robotino>> camera-get-image drop raw>image flip 
    >>image relayout-1 ] [ drop ] if ;

: disp ( robotino -- )
    <camera-gadget> dup update-image "coucou" open-window ;
M: camera-gadget graft* [ [ update-image ] curry 20 milliseconds every ] keep (>>update-thread) ;
M: camera-gadget ungraft* update-thread>> cancel-alarm ;
M: camera-gadget pref-dim* drop { 320 240 } ;
M: camera-gadget draw-gadget*
    image>> [
        draw-line
    ] each-index ;

\ camera-gadget H{
    { T{ button-down } [ [ not ] change-on? drop ] }
} set-gestures
