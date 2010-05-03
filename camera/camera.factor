! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors
kernel opengl sequences ui.render ui.gadgets grouping ui math calendar threads 
alarms ui.gestures factorino.basics images.viewer ;
IN: factorino.camera

TUPLE: camera-gadget < gadget robotino image { on? initial: f } update-thread ;
: draw-pixel ( pixel y x -- )
    [ [ 255 / ] { } map-as first3 1 <rgba> gl-color ] 2dip 
    swap 2array { 1 1 } gl-rect ;
: draw-line ( line # -- )
    [ draw-pixel ] curry each-index ;
: raw>image ( raw -- image ) 3 <sliced-groups> 320 <sliced-groups> ;
: <camera-gadget> ( robotino -- gadget )
    camera-gadget new swap >>robotino ;
: (update-image) ( camera-gadget -- )
    ! TODO: check that we didn't change resolution..
    dup image>> [
        [ robotino>> ] [ image>> ] bi (camera-get-image)
    ] [
        [ robotino>> camera-get-image drop ] keep (>>image) ]
    if ;

: update-image ( camera-gadget -- )
    dup on?>> [
        [ (update-image) ] [ relayout-1 ] bi ]
    [ drop ] if ;

: disp ( robotino -- )
    <camera-gadget> dup update-image "coucou" open-window ;
M: camera-gadget pref-dim* drop { 320 240 } ;
M: camera-gadget draw-gadget*
    ! TODO : understand image. to display images !!
    image>> drop ;
    !  [ image. ] when* ;
: start-refreshing ( gadget -- )
    [ robotino>> t camera-set-streaming ]
    [ [ [ update-image ] curry 20 milliseconds every ] keep (>>update-thread) ] bi ;
: stop-refreshing ( gadget -- )
    [ robotino>> f camera-set-streaming ]
    [ update-thread>> cancel-alarm ] bi ;
: handle-down ( gadget -- )
    [ not ] change-on?
    dup on?>> [ start-refreshing ] [ stop-refreshing ] if ; 

\ camera-gadget H{
    { T{ button-down } [ handle-down ] }
} set-gestures
