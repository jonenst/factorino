! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays continuations combinators factorino.basics kernel
ui.gadgets ui.gadgets.buttons ui.gadgets.packs ui.gestures ;
IN: factorino.controller

TUPLE: controller < pack current-robotino
{ vx initial: 0.0 } { vy initial: 0.0 } { theta initial: 0.0 } ; 

: silent-kill ( controller -- )
    current-robotino>> [ kill-robotino ] curry [ drop ] recover ;
: handle-init ( button controller -- )
    nip 
    [ silent-kill ]
    [ <init-robotino> >>current-robotino drop ] bi ;
: handle-kill ( button controller -- ) nip silent-kill ;
: init-button ( controller -- button )
    [ "init" ] dip [ handle-init ] curry <border-button> ;
: controller-kill-button ( controller -- button )
    [ "kill" ] dip [ handle-kill ] curry <border-button> ;
: <controller> ( -- controller )
    controller new horizontal >>orientation
    dup init-button add-gadget 
    dup controller-kill-button add-gadget
    ;
: apply-speed ( controller -- )
    { [ current-robotino>> ] [ vx>> ] [ vy>> 2array ] [ theta>> ] } cleave
    omnidrive-set-velocity ;
\ controller H{
    { T{ key-down f f "s" } [ -500 >>vx apply-speed ] } 
    { T{ key-down f f "z" } [ 500 >>vx apply-speed ] } 
    { T{ key-up f f "s" } [ 00 >>vx apply-speed ] } 
    { T{ key-up f f "z" } [ 00 >>vx apply-speed ] } 
    { T{ key-down f f "a" } [ 500 >>vy apply-speed ] } 
    { T{ key-down f f "e" } [ -500 >>vy apply-speed ] } 
    { T{ key-up f f "a" } [ 00 >>vy apply-speed ] } 
    { T{ key-up f f "e" } [ 00 >>vy apply-speed ] } 
    { T{ key-down f f "q" } [ 60 >>theta apply-speed ] } 
    { T{ key-down f f "d" } [ -60 >>theta apply-speed ] } 
    { T{ key-up f f "q" } [ 00 >>theta apply-speed ] } 
    { T{ key-up f f "d" } [ 00 >>theta apply-speed ] } 
    } set-gestures
