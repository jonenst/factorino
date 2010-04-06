! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: factorino.maps.general

CONSTANT: UNEXPLORED  0
CONSTANT: OBSTACLE    1
CONSTANT: FREE        2
CONSTANT: UNREACHABLE 3
GENERIC: init ( size map -- map )
GENERIC: neighbours ( {i,j} map -- neighbours )
GENERIC: set-state ( state {i,j} map -- )
GENERIC: state ( {i,j} map -- state )
GENERIC: all-obstacles ( map -- obstacles  )
GENERIC: draw-map ( gadget map --  )
GENERIC: map-size ( map -- size )
GENERIC: random-unexplored ( map -- pos )

: set-obstacle ( {i,j} map obstacle? -- ) OBSTACLE FREE ? -rot set-state ;
: is-obstacle? ( {i,j} map -- ? ) state OBSTACLE = ;
: <map> ( size class -- map ) new init ;
: toggle-obstacle ( {i,j} map -- ) 
    2dup is-obstacle? not set-obstacle ;
