! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors
kernel opengl sequences ui.render ui.gadgets grouping ui math calendar threads 
timers ui.gestures factorino.basics images images.viewer ui.gadgets.packs 
combinators.short-circuit factorino.utils io continuations literals images.loader ui.gadgets.books 
namespaces models images.jpeg ;
FROM: models => change-model ;
IN: factorino.camera

SYMBOL: no-signal-image

TUPLE: camera-gadget < book robotino image-control { on? initial: f } ;
: load-default-image ( -- image )
    "resource:work/factorino/camera/no-signal.jpg" load-image [ no-signal-image set ] keep ;
: default-image ( -- image )
    no-signal-image get [ load-default-image ] unless* ;
: register-camera ( camera-gadget robotino -- ) >>robotino drop ;
: unregister-camera ( camera-gadget -- )
    [ image-control>> ] [ robotino>> ] bi [ unregister-camera-observer ] [ drop ] if* ;
: handle-down ( gadget -- )
    [ not ] change-on?
    dup model>> [ 1 swap - ] change-model
    [ [ image-control>> ] [ robotino>> ] bi ] keep
    on?>> [ register-camera-observer ] [ unregister-camera-observer ] if ; 
: <camera-gadget>* ( -- gadget )
    0 <model> camera-gadget new-book
    default-image <image-gadget> add-gadget
    image-control new-image-gadget >>image-control dup image-control>> add-gadget 
    ;
: <camera-gadget> ( robotino -- gadget )
    <camera-gadget>* swap >>robotino ;
: disp ( robotino -- )
    <camera-gadget> "coucou" open-window ;
M: camera-gadget pref-dim* drop { 300 300 } ;
\ camera-gadget H{
    { T{ button-down } [ handle-down ] }
} set-gestures
