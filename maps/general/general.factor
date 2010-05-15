! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences math.order ;
IN: factorino.maps.general

CONSTANT: UNEXPLORED   0
CONSTANT: FREE         2
CONSTANT: UNREACHABLE  3
CONSTANT: ROBOTINO     4
CONSTANT: CURRENT-PATH 5
CONSTANT: OBSTACLE     10
CONSTANT: MAX-OBSTACLE 100
GENERIC: init ( size map -- map )
GENERIC: neighbours ( {i,j} map -- neighbours )
GENERIC: set-state ( state {i,j} map -- )
GENERIC: state ( {i,j} map -- state )
GENERIC: all-obstacles ( map -- obstacles  )
GENERIC: draw-map ( gadget map --  )
GENERIC: map-size ( map -- size )
GENERIC: random-unexplored ( map -- pos )

: (is-obstacle?) ( state -- ? ) OBSTACLE >= ;
: is-obstacle? ( {i,j} map -- ? ) state (is-obstacle?) ;
: <map> ( size class -- map ) new init ;

CONSTANT: OBSTACLE-INCREMENT-FACTOR 2
CONSTANT: OBSTACLE-INCREMENT-OFFSET 20
: change-state ( {i,j} map quot: ( state -- new-state ) -- )
    [ state ] prepose 2keep set-state ; inline
: (increment-obstacle) ( obstacle -- new-obstacle )
    OBSTACLE - OBSTACLE-INCREMENT-FACTOR * OBSTACLE-INCREMENT-OFFSET + OBSTACLE + ;
: increment-obstacle ( obstacle -- new-obstacle )
    (increment-obstacle) OBSTACLE MAX-OBSTACLE clamp ;
: decay-ij ( {i,j} map -- )
    [ dup MAX-OBSTACLE < [ 1 - dup OBSTACLE < [ drop FREE ] when ] when ] change-state ;
: decay ( map -- )
    [ all-obstacles ] keep [ decay-ij ] curry each ;

: set-obstacle ( {i,j} map obstacle? -- ) 
    [
        [ dup (is-obstacle?) [ drop OBSTACLE ] unless increment-obstacle ]
        [ drop FREE ] if
    ] curry change-state ;
: toggle-obstacle ( {i,j} map -- ) 
    2dup is-obstacle? not set-obstacle ;
