! Copyright (C) 2010 Jon Harper. 
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factorino.basics math math.constants math.vectors factorino.utils ;
IN: factorino.basics.tests


[ 0.75 ] [ 0 20 15 calc-barycentre >float ] unit-test
[ 15.0 ] [ 0 20 0.75 barycentre >float ] unit-test
[ 30.0 ] [ 0 20 1.5 barycentre >float ] unit-test
[ 0.0 ] [ 10 20 -1 barycentre >float ] unit-test

[ 5.0 ] [ { { 0 1 } { 2 3 } { 4 5 } { 6 10 } } 7.5 value>distance >float ] unit-test
[ 6.0 ] [ { { 0 0 } { 2 4 } } 12 value>distance >float ] unit-test
[ -6.0 ] [ { { 0 0 } { 2 4 } } -12 value>distance >float ] unit-test

[ t ] [ { 1 0 } pi 2 / rotate { 0 1 } 0.0001 v~ ] unit-test

