! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit factorino.utils io destructors
io.encodings.ascii io.sockets kernel locals math math.functions
math.parser sequences splitting calendar io.timeouts namespaces 
continuations ;
FROM: factorino.basics => com-address* ;
IN: factorino.imu
CONSTANT: port 54321

:: quaternion>yaw ( q0 q1 q2 q3 -- yaw )
    q1 q2 * q0 q3 * - 2 *
    1 q2 q3 [ sq ] bi@ + 2 * - rect> arg ;

: check-parsed ( parsed -- ? )
    { [ length 14 = ] [ [ ] all? ] } 1&& ;
: parse-line ( line -- parsed/f )
    dup last CHAR: \n = [ 1 head* ] when
    "," split [ string>number ] map
    dup check-parsed [ drop f ] unless ;
: initiate ( adress datagramm -- )
[ B{ 0 } ] 2dip send ;
: receive-parsed ( datagram -- parsed )
    dup receive drop parse-line [ nip ] [ receive-parsed
    ] if* ;
: (get-line) ( address datagram -- result )
    [
        [ 200 milliseconds swap set-timeout ]
        [ [ port <inet4> ] dip initiate ]
        [ [ receive-parsed first4 quaternion>yaw ] with-timeout ] tri
    ] with-disposal ;
: get-line ( address -- result )
    f port <inet4> <datagram> [ (get-line) ] 2curry [ drop f ] recover ;
: imu-angle ( adress -- angle )
    get-line dup [ to-degrees ] when ; 
: imu-phi ( robotino -- angle? )
    com-address* imu-angle ; 
: imu-phi* ( robotino -- angle )
    dup imu-phi [ nip ] [ imu-phi* ] if* ;

: imu-temp ( -- )
f [ drop readln dup . parse-line dup not ] loop first4 quaternion>yaw to-degrees . yield ;

: imu-lol ( -- )
"/dev/ttyACM0" utf8 [ 100 [ imu-temp ] times ] with-file-reader ;
