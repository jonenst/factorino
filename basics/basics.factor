! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays calendar combinators
combinators.short-circuit delegate kernel locals math
math.constants math.functions math.order math.vectors
namespaces prettyprint sequences system threads
factorino.bindings factorino.functor ui ui.gadgets.buttons ;
IN: factorino.basics


TUPLE: robotino com-id omnidrive-id bumper-id sensors-id odometry-id camera-id ;
: throw-when-false ( return-code -- ) FALSE = [ "You're fucked" throw ] when ;

: to-degrees ( radian -- degrees ) 180 * pi / ;
: to-radian ( degrees -- radian ) pi * 180 / ;

: rotate ( vect angle -- vect' ) 
    [ first2 ] [ [ cos ] [ sin ] bi ] bi*
    [| x y cos sin | x cos * y sin * -
                     x sin * y cos * + 2array ] call ;
: rotate-degrees ( vect angle -- vect' ) 
    to-radian rotate ;

GENERIC: com-destroy* ( identifier -- )
GENERIC: com-set-address* ( address identifier -- )
GENERIC: com-address* ( identifier -- address/f )
GENERIC: com-set-image-server-port* ( port identifier -- )
GENERIC: com-connect* ( identifier -- )
GENERIC: com-disconnect* ( identifier -- )
GENERIC: com-connected?* ( identifier -- )
GENERIC: com-wait-for-update* ( identifier -- )

PROTOCOL: com-protocol 
    com-destroy* com-set-address* com-address* com-set-image-server-port*
    com-connect* com-disconnect* com-connected?* com-wait-for-update* ;
CONSULT: com-protocol robotino com-id>> ;

ROBOTINO-WORD: bumper
! TODO make this more generic
! GENERIC: bumper-destroy* ( identifier -- )
! M: f bumper-destroy* drop ;
! M: integer bumper-destroy* Bumper_destroy throw-when-false ;
! PROTOCOL: bumper-protocol bumper-destroy* ;
! CONSULT: bumper-protocol robotino bumper-id>> ;

GENERIC: omnidrive-destroy* ( identifier -- )
M: f omnidrive-destroy* drop ;
M: integer omnidrive-destroy* OmniDrive_destroy throw-when-false ;
PROTOCOL: omnidrive-protocol omnidrive-destroy* ;
CONSULT: omnidrive-protocol robotino omnidrive-id>> ;

GENERIC: sensors-destroy* ( identifier -- )
M: f sensors-destroy* drop ;
M: integer sensors-destroy* DistanceSensor_destroy throw-when-false ;
M: array sensors-destroy* [ sensors-destroy* ] each ;
PROTOCOL: sensors-protocol sensors-destroy* ;
CONSULT: sensors-protocol robotino sensors-id>> ;

: num-distance-sensors ( -- n ) numDistanceSensors ; 




M: integer com-connect* Com_connect throw-when-false ; 
M: integer com-disconnect* Com_disconnect throw-when-false ; 
M: integer com-destroy* Com_destroy throw-when-false ;
M: integer com-wait-for-update* Com_waitForUpdate throw-when-false ;
M: integer com-address* 
    256 dup <byte-array>
    [ swap Com_address throw-when-false ] keep ;
M: integer com-set-address* swap Com_setAddress throw-when-false ;

: omnidrive-construct ( robotino -- ) 
    OmniDrive_construct >>omnidrive-id
    [ omnidrive-id>> ] [ com-id>> ] bi
    OmniDrive_setComId throw-when-false ;
: omnidrive-destroy ( robotino -- ) omnidrive-id>> OmniDrive_destroy throw-when-false ;
: omnidrive-set-velocity ( robotino v omega -- )
    [ [ omnidrive-id>> ] dip first2 ] dip OmniDrive_setVelocity throw-when-false ;

: bumper-construct ( robotino -- )
    Bumper_construct >>bumper-id
    [ bumper-id>> ] [ com-id>> ] bi
    Bumper_setComId throw-when-false ;
: bumper-destroy ( robotino -- ) bumper-id>> Bumper_destroy throw-when-false ;

: sensor-id-at ( # robotino -- sensor-id ) sensors-id>> nth ;
: distance-sensor-construct ( # robotino -- )
    [ [ DistanceSensor_construct ] keep ]
    [ sensors-id>> ] bi* set-nth ;
: associate-sensor ( # robotino -- ) 
    [ sensor-id-at ] keep com-id>> DistanceSensor_setComId throw-when-false ;
: init-sensor ( # robotino -- )
    [ distance-sensor-construct ] [ associate-sensor ] 2bi ;
: init-all-sensors ( robotino -- ) 
    num-distance-sensors iota [ swap init-sensor ] with each ;
: distance-sensor-destroy ( # robotino -- )
    sensor-id-at DistanceSensor_destroy throw-when-false ;
:: distance-sensor-set-com-id ( # com-id robotino -- )
    # robotino sensor-id-at com-id DistanceSensor_setComId throw-when-false ;
: distance-sensor-voltage ( # robotino -- value ) sensor-id-at DistanceSensor_voltage ;
: distance-sensor-heading ( # robotino -- value ) sensor-id-at DistanceSensor_heading ;

: sensors-values ( robotino -- values ) sensors-id>> [ dup [ DistanceSensor_voltage ] when ] map ;
: sensors-headings ( robotino -- values ) sensors-id>> [ dup [ DistanceSensor_heading ] when ] map ;

: sensor-distance ( value -- distance ) 0.1 + recip ;

: odometry-construct ( robotino -- ) 
    Odometry_construct >>odometry-id 
    [ odometry-id>> ] [ com-id>> ] bi 
    Odometry_setComId throw-when-false ;
: odometry-destroy ( robotino -- ) odometry-id>> Odometry_destroy throw-when-false ;
: odometry-x ( robotino -- x ) odometry-id>> Odometry_x ;
: odometry-y ( robotino -- y ) odometry-id>> Odometry_y ;
: odometry-xy ( robotino -- {x,y} ) [ odometry-x ] [ odometry-y ] bi 2array ;
: odometry-phi ( robotino -- phi ) odometry-id>> Odometry_phi ;
: odometry-set ( robotino {x,y,phi} -- ) [ odometry-id>> ] [ first3 ] bi* Odometry_set throw-when-false ;
: odometry-reset ( robotino -- ) { 0 0 0 } odometry-set ;

: calc-angle ( previous-time -- angle current-time ) 
    nano-count [ - pi 2 * * 9 10 ^ / ] keep ;
:: (drive) ( robotino vector previous-time -- )
    previous-time calc-angle :> new-time :> angle
    vector angle rotate :> new-vector
    robotino new-vector 0 omnidrive-set-velocity
    50 milliseconds sleep 
    robotino new-vector new-time (drive) ;
: drive ( robotino -- ) { 200 0 } nano-count (drive) ;

: new-robotino ( address class -- robotino ) 
    new
    num-distance-sensors f <array> >>sensors-id
    Com_construct >>com-id
    [ com-set-address* ]
    [ com-connect* ] 
    [ ] tri ;
: <robotino> ( address -- robotino ) 
    \ robotino new-robotino ;
: robotino-test ( adress -- )
    <robotino> dup omnidrive-construct drive ; 
: kill-robotino ( robotino -- )
    { 
        [ sensors-destroy* ]
        [ bumper-destroy* ]
        [ omnidrive-destroy* ]
        [ com-destroy* ] 
    } cleave ;
: kill-button ( robotino -- robotino )
    "KILL ME!" over [ kill-robotino drop ] curry <border-button> [ "kill-switch" open-window ] curry with-ui ;

: <button-robotino> ( adress -- robotino )
    <robotino> kill-button ;


: <init-robotino> ( adress -- robotino )
    <button-robotino>
    [ omnidrive-construct ] [ odometry-construct ] [ ] tri ;
