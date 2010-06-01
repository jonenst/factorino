! Copyright (C) 2010 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factorino.asserv factorino.asserv.private ;
IN: factorino.asserv.tests

[ 40 ] [ 20 60 angular-distance ] unit-test
[ 40 ] [ 20 -20 angular-distance ] unit-test
[ 40 ] [ 20 340 angular-distance ] unit-test

[ 0.0 ] [ { 1 0 } >padding ] unit-test
[ 90.0 ] [ { 0 1 } >padding ] unit-test
[ 180 ] [ { -1 0 } >padding ] unit-test
[ -90.0 ] [ { 0 -1 } >padding ] unit-test

[ t ] [ 40 { 20 50 } in-range ] unit-test
[ f ] [ 10 { 20 50 } in-range ] unit-test
[ f ] [ -50 { 10 30 } in-range ] unit-test

[ { 8.0 16.0 } ] [ { 0 0 } { 10 20 } (merge-vectors) ] unit-test
