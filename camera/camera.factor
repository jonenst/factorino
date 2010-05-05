! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays colors
kernel opengl sequences ui.render ui.gadgets grouping ui math calendar threads 
alarms ui.gestures factorino.basics images images.viewer ui.gadgets.packs 
combinators.short-circuit factorino.utils io continuations literals ;
IN: factorino.camera

TUPLE: camera-gadget < pack robotino { image-control initial: $[ image-control new ] } { on? initial: f } ;

: handle-down ( gadget -- )
    [ not ] change-on?
    [ [ image-control>> ] [ robotino>> ] bi ] keep
    on?>> [ register-camera-observer ] [ unregister-camera-observer ] if ; 
: <camera-gadget> ( robotino -- gadget )
    camera-gadget new horizontal >>orientation swap >>robotino ;
: disp ( robotino -- )
    <camera-gadget> "coucou" open-window ;
M: camera-gadget pref-dim* drop { 300 300 } ;
\ camera-gadget H{
    { T{ button-down } [ handle-down ] }
} set-gestures
