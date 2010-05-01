! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: math arrays kernel math.constants sequences math.functions locals ui.tools.listener prettyprint io ;
IN: factorino.utils

: to-degrees ( radian -- degrees ) 180 * pi / ;
: to-radian ( degrees -- radian ) pi * 180 / ;
: rotate ( vect angle -- vect' ) 
    [ first2 ] [ [ cos ] [ sin ] bi ] bi*
    [| x y cos sin | x cos * y sin * -
                     x sin * y cos * + 2array ] call ;
: rotate-degrees ( vect angle -- vect' ) 
    to-radian rotate ;

: barycentre ( a b x -- c )
    [ [ swap - ] dip * ] [ 2drop ] 3bi + ;
: calc-barycentre ( a b c -- x )
    rot [ - ] curry bi@ swap / ;

: debug ( object -- object ) dup get-listener listener-streams [ . ] with-streams* ;
