! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: factorino.maps.general

CONSTANT: UNEXPLORED 0
CONSTANT: OBSTACLE   1
CONSTANT: FREE       2
GENERIC: init ( size map -- map )
GENERIC: neighbours ( {i,j} map -- neighbours )
GENERIC# set-state 1 ( {i,j} map state -- )
GENERIC: state ( {i,j} map -- state )
GENERIC: all-obstacles ( map -- obstacles )
GENERIC: map-size ( map -- size )

: set-obstacle ( {i,j} map obstacle? -- ) OBSTACLE FREE ? set-state ;
: is-obstacle? ( {i,j} map -- ? ) state OBSTACLE = ;
: <map> ( size class -- map ) new init ;
: toggle-obstacle ( {i,j} map -- ) 
    2dup is-obstacle? not set-obstacle ;
