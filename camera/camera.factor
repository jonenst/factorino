! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors
kernel opengl sequences ui.render ui.gadgets grouping ui math calendar threads 
alarms ui.gestures factorino.basics images images.viewer ui.gadgets.packs ;
IN: factorino.camera

TUPLE: camera-gadget < pack robotino image-gadget { on? initial: t } update-thread ;
: <robotino-image> ( bits dim -- image )
    <image> swap >>dim swap >>bitmap RGB >>component-order ubyte-components >>component-type ;
: new-gadget-needed? ( camera-gadget -- ? )
    image-gadget>> not ;
: (update-image) ( camera-gadget -- )
    ! TODO: check that we didn't change resolution..
    dup new-gadget-needed?
    [
        [ robotino>> camera-get-image [ <robotino-image> <image-gadget> ] when* ] keep 
        [ (>>image-gadget) ] [ swap [ add-gadget relayout-1 ] [ drop ] if* ] 2bi ]
    [ 
    [ [ robotino>> ] [ image-gadget>> image>> bitmap>> ] bi camera-get-image* ]
        [ image-gadget>> f >>texture relayout-1 ] bi
    ]     if ;
M: camera-gadget pref-dim* image-gadget>> [ pref-dim* ] [ { 320 240 } ] if* ;
: update-image ( camera-gadget -- )
    dup on?>> [
        [ (update-image) ] [ relayout-1 ] bi ]
    [ drop ] if ;

: start-refreshing ( gadget -- )
    [ robotino>> t camera-set-streaming ]
    [ [ [ update-image ] curry 1 15 / seconds every ] keep (>>update-thread) ] bi ;
: stop-refreshing ( gadget -- )
    [ robotino>> f camera-set-streaming ]
    [ update-thread>> [ cancel-alarm ] when* ] bi ;
: handle-down ( gadget -- )
    [ not ] change-on?
    dup on?>> [ start-refreshing ] [ stop-refreshing ] if ; 
M: camera-gadget ungraft* stop-refreshing ;
: <camera-gadget> ( robotino -- gadget )
    camera-gadget new horizontal >>orientation swap >>robotino dup start-refreshing ;
: disp ( robotino -- )
    <camera-gadget> dup update-image "coucou" open-window ;
\ camera-gadget H{
    { T{ button-down } [ handle-down ] }
} set-gestures
