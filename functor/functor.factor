! Copyright (C) 2010 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: factorino.types functors kernel math delegate lexer
parser unicode.case ;
IN: factorino.functor

FUNCTOR: define-robotino-word ( WORD CAPITALIZED -- )
    
    WORD-destroy* DEFINES ${WORD}-destroy*
    WORD-protocol DEFERS ${WORD}-protocol
    WORD-id>> IS ${WORD}-id>>
    CAPITALIZED IS ${CAPITALIZED}_destroy
    WORD-protocol DEFERS ${WORD}-protocol
    
    WHERE

    GENERIC: WORD-destroy* ( identifier -- )
    M: POSTPONE: f WORD-destroy* drop ;
    M: integer WORD-destroy* CAPITALIZED throw-when-false ;
    M: robotino WORD-destroy* WORD-id>> WORD-destroy* ;
;FUNCTOR
SYNTAX: ROBOTINO-WORD: scan scan define-robotino-word ;


