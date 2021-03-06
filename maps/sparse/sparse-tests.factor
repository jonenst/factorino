! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factorino.maps.sparse factorino.maps.general 
sequences kernel literals memoize math ;
IN: factorino.maps.sparse.tests

MEMO: test-map ( -- map )
    { 
        { $ OBSTACLE { 0 0 } }
        { $ FREE { 0 1 } }
        { $ UNEXPLORED { 0 2 } }
        { $ UNEXPLORED { 0 3 } }
        { $ OBSTACLE { 0 3 } }
    }
    { 10 10 } \ sparse-map <map> 
    [ [ [ first2 ] dip set-state ] curry each ] keep ;
 
[ ${ OBSTACLE FREE UNEXPLORED OBSTACLE } ] 
    [ { { 0 0 } { 0 1 } { 0 2 } { 0 3 } } [ test-map state ] map ] unit-test
[ 2 ] [ test-map all-obstacles length ] unit-test
[ 3 ] [ { 0 1 } test-map neighbours ] unit-test

[ ] [ { 0 3 } test-map t set-obstacle ] unit-test
[ ] [ 10 [ test-map decay ] times ] unit-test
[ { f t } ] [ { { 0 0 } { 0 3 } } [ test-map state (is-obstacle?) ] map ] unit-test
[ ] [ 15 [ test-map decay ] times ] unit-test
[ { f f } ] [ { { 0 0 } { 0 3 } } [ test-map state (is-obstacle?) ] map ] unit-test
