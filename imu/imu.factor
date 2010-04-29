! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit io io.encodings.ascii
io.sockets kernel locals math math.functions math.parser
sequences splitting ;
IN: factorino.imu

:: quaternion>yaw ( q0 q1 q2 q3 -- yaw )
    q1 q2 * q0 q3 * - 2 *
1 q2 q3 [ sq ] bi@ + 2 * - rect> arg ;

: check-parsed ( parsed -- ? )
    { [ length 14 = ] [ [ ] all? ] } 1&& ;
: parse-line ( line -- parsed/f )
    "," split [ string>number ] map
    dup check-parsed [ drop f ] unless ;
: get-line ( adress -- parsed )
    54321 <inet> ascii [ readln ] with-client parse-line ;
: calc ( adress -- angle )
    get-line first4 quaternion>yaw to-degrees ; 
