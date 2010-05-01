! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit factorino.utils io destructors
io.encodings.ascii io.sockets kernel locals math math.functions
math.parser sequences splitting calendar io.timeouts namespaces 
continuations prettyprint threads io.encodings.utf8 io.files ;
IN: factorino.imu

:: quaternion>yaw ( q0 q1 q2 q3 -- yaw )
    q1 q2 * q0 q3 * - 2 *
    1 q2 q3 [ sq ] bi@ + 2 * - rect> arg ;

: check-parsed ( parsed -- ? )
    { [ length 14 = ] [ [ ] all? ] } 1&& ;
: parse-line ( line -- parsed/f )
    dup last CHAR: \n = [ 1 head* ] when
    "," split [ string>number ] map
    dup check-parsed [ drop f ] unless ;
: receive-parsed ( -- parsed )
    readln parse-line [ receive-parsed
    ] unless* ;
: imu-angle ( -- angle )
    receive-parsed first4 quaternion>yaw to-degrees ;

: imu-temp ( -- )
f [ drop readln dup . parse-line dup not ] loop first4 quaternion>yaw to-degrees . yield ;
: imu-lol ( -- )
"/dev/ttyACM0" utf8 [ 100 [ imu-temp ] times ] with-file-reader ;
