! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factorino.driving.utils ;
IN: factorino.driving.utils.tests

! cell-size = 100 ?
[ { 0 0 } ] [ { 0 0 } {x,y}>{i,j} ] unit-test 
[ { 3 2 } ] [ { 278 234 } {x,y}>{i,j} ] unit-test 
[ { -5 3 } ] [ { -549 251 } {x,y}>{i,j} ] unit-test 
[ { 300 0 } ] [ { 3 0 } {i,j}>{x,y} ] unit-test
