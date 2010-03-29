! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: factorino.maps.general

GENERIC: init ( size map -- map )
: <map> ( size class -- map ) new init ;
GENERIC: neighbours ( {i,j} map -- neighbours )
GENERIC: set-obstacle ( {i,j} map -- )
GENERIC: all-obstacles ( map -- obstacles )
