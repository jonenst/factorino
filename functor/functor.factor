! Copyright (C) 2010 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: functors kernel math
parser ;
IN: factorino.functor

  !  C-WORD DEFERS ${WORD}
    ! WORD-destroy* DEFERS ${WORD}-destroy*
    ! WORD-protocol DEFERS ${WORD}-protocol
    ! WORD-id>> IS ${WORD}-id>>
FUNCTOR: define-robotino-word ( WORD -- )
    
    
    WHERE

   ! GENERIC: WORD-destroy* ( identifier -- )
   ! M: f WORD-destroy* drop ;
   ! M: integer WORD-destroy* drop ; ! C-WORD throw-when-false ;
!    M: robotino WORD-destroy* WORD-id>> WORD-destroy* ;
    ! PROTOCOL: WORD-protocol WORD-destroy* ;
    ! CONSULT: WORD-protocol robotino WORD-id>> ;
;FUNCTOR
SYNTAX: ROBOTINO-WORD: scan-word define-robotino-word ;


