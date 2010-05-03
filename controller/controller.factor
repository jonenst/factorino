! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations combinators factorino.basics kernel
ui.gadgets ui.gadgets.buttons ui.gadgets.packs ui.gestures math locals sequences
ui.tools.listener ui factorino.camera ;
IN: factorino.controller
<PRIVATE
TUPLE: controller < pack current-robotino
{ vx initial: 0.0 } { vy initial: 0.0 } { theta initial: 0.0 } { multiplier initial: 1 } ; 
: get-camera-gadget ( controller -- camera-gadget )
    children>> [ camera-gadget? ] filter first ; 
: init-camera-gadget ( controller -- )
    [ get-camera-gadget ] [ current-robotino>> dup camera-init >>robotino ] bi f >>on? drop ;
: silent-kill ( controller -- )
    current-robotino>> [ kill-robotino ] curry [ drop ] recover ;
: handle-init ( button controller -- )
    nip 
    [ silent-kill ]
    [ <init-robotino> >>current-robotino drop ]
    [ init-camera-gadget ] tri ;
: handle-kill ( button controller -- ) nip [ silent-kill ]
[ children>> [ camera-gadget? ] filter first f >>on? drop ] bi ;
: init-button ( controller -- button )
    [ "init" ] dip [ handle-init ] curry <border-button> ;
: controller-kill-button ( controller -- button )
    [ "kill" ] dip [ handle-kill ] curry <border-button> ;
:: (apply-speed) ( controller theta-quot -- )
    controller 
    { 
        [ current-robotino>> ] [ vx>> ] [ vy>> ]
        [ multiplier>> [ * ] curry bi@ 2array ] theta-quot } cleave
    omnidrive-set-velocity ; inline
: robotino-push ( controller -- robotino ) current-robotino>> ;
: apply-speed ( controller -- )
    [ theta>> ] (apply-speed) ; 
\ controller H{
    { T{ key-down f f "s" } [ -500 >>vx apply-speed ] } 
    { T{ key-up f f "s" } [ 00 >>vx apply-speed ] } 
    { T{ key-down f f "z" } [ 500 >>vx apply-speed ] } 
    { T{ key-up f f "z" } [ 00 >>vx apply-speed ] } 
    { T{ key-down f f "a" } [ 500 >>vy [ drop 0 ] (apply-speed) ] } 
    { T{ key-up f f "a" } [ 00 >>vy [ drop 0 ] (apply-speed) ] } 
    { T{ key-down f f "e" } [ -500 >>vy apply-speed ] } 
    { T{ key-up f f "e" } [ 00 >>vy apply-speed ] } 
    { T{ key-down f f "q" } [ 60 >>theta apply-speed ] } 
    { T{ key-up f f "q" } [ 00 >>theta apply-speed ] } 
    { T{ key-down f f "d" } [ -60 >>theta apply-speed ] } 
    { T{ key-up f f "d" } [ 00 >>theta apply-speed ] } 
    { T{ key-down f f "f" } [ [ 1.1 * ] change-multiplier drop ] }
    { T{ key-down f f "r" } [ [ 0.9 * ] change-multiplier drop ] }
    { T{ key-down f f "p" } [ [ robotino-push ] curry dup last call-listener ] }
    } set-gestures

: <controller> ( -- controller )
    controller new horizontal >>orientation
    dup init-button add-gadget 
    dup controller-kill-button add-gadget
    camera-gadget new add-gadget 
    ;
PRIVATE>
: controller ( -- )
    [ <controller> "controller" open-window ] with-ui ;
