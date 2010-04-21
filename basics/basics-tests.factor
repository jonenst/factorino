! Copyright (C) 2010 Jon Harper. 
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factorino.basics ;
IN: factorino.basics.tests


[ 3/4 ] [ 0 20 15 calc-barycentre ] unit-test
[ 15.0 ] [ 0 20 0.75 barycentre ] unit-test

[ 5.0 ] [ { { 0 1 } { 2 3 } { 4 5 } { 6 10 } } 7.5 value>distance ] unit-test
