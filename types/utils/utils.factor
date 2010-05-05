! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: images kernel accessors ;
IN: factorino.types.utils

: <robotino-image> ( bits dim -- image )
    <image> swap >>dim swap >>bitmap RGB >>component-order ubyte-components >>component-type ;
