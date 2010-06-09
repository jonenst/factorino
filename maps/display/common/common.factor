! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: colors ui.gadgets math.rectangles kernel accessors math.vectors 
math sequences opengl math.functions 
factorino.maps.general colors.constants 
factorino.utils
combinators ;
IN: factorino.maps.display.common

TUPLE: map-gadget < gadget map zoom origin-offset in-drag-origin-offset current-path robotino-position ; 

: screen-size ( gadget -- dim ) rect-bounds nip ;
: screen-cell-size ( gadget -- dim ) [ screen-size ] [ zoom>> ] bi v* [ round >integer ] map ;

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

: black ( -- color ) 0 0 0 1 <rgba> ;
: set-state-color ( state -- )
    { 
        { FREE        [ COLOR: green ] }
        { UNEXPLORED  [ COLOR: yellow ] } 
        { UNREACHABLE [ COLOR: red ] } 
        { ROBOTINO    [ COLOR: pink ] } 
        { CURRENT-PATH [ COLOR: cyan ] } 
        [ OBSTACLE - MAX-OBSTACLE /f 1 swap - dup dup 1 <rgba> ]
    } case gl-color ;

: draw-state ( pos map-gadget state -- )
    [ [ swap map>screen ] keep screen-cell-size ]
    [ set-state-color ] bi* gl-fill-rect ;
