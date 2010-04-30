! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test factorino.imu math.functions ;
IN: factorino.imu.tests


[ { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 } ] [ "0,1,2,3,4,5,6,7,8,9,10,11,12,13" parse-line ] unit-test
[ t ] [ -0.1 0.4 0.9 0.4 quaternion>yaw -0.8656849786804649 0.00001 ~ ] unit-test
