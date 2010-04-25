! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: colors ui.gadgets math.rectangles kernel accessors math.vectors 
math sequences opengl math.functions factorino.maps.general colors.constants 
combinators ;
IN: factorino.maps.display.common

TUPLE: map-gadget < gadget map zoom origin-offset in-drag-origin-offset ; 

: screen-size ( gadget -- dim ) rect-bounds nip ;
: screen-cell-size ( gadget -- dim ) [ screen-size ] [ zoom>> ] bi v* [ round >integer ] map ;

: invert-y ( {x,y} -- {x,-y} ) clone [ 1 swap [ neg ] change-nth ] keep ;
: invert-x ( {x,y} -- {x,-y} ) clone [ 0 swap [ neg ] change-nth ] keep ;
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
        { OBSTACLE    [ COLOR: black ] }
        { UNEXPLORED  [ COLOR: gray ] } 
        { UNREACHABLE [ COLOR: red ] } 
        [ drop COLOR: white ]
    } case gl-color ;

: draw-state ( pos map-gadget state -- )
    [ [ swap map>screen ] keep screen-cell-size ]
    [ set-state-color ] bi* gl-fill-rect ;

: draw-obstacle ( obstacle map-gadget -- ) 
        OBSTACLE draw-state ;
