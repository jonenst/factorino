! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays byte-arrays calendar combinators
combinators.short-circuit delegate kernel locals math
math.constants math.functions math.order math.vectors
namespaces prettyprint sequences system threads
factorino.bindings factorino.functor factorino.types ui ui.gadgets.buttons ;
IN: factorino.basics

TUPLE: position {x,y} phi ;
: fix-angle ( angle -- newangle )
    360 rem dup 180 > [ 360 - ] when ;
: <position> ( {x,y} phi -- position )
    dup [ fix-angle ] when position boa ;

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

ROBOTINO-WORD: bumper Bumper
ROBOTINO-WORD: omnidrive OmniDrive
ROBOTINO-WORD: sensors DistanceSensor
M: array sensors-destroy* [ sensors-destroy* ] each ;


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
    T{ position f { 0 0 } 0 } >>current-direction
    OmniDrive_construct >>omnidrive-id
    [ omnidrive-id>> ] [ com-id>> ] bi
    OmniDrive_setComId throw-when-false ;
: omnidrive-destroy ( robotino -- ) omnidrive-id>> OmniDrive_destroy throw-when-false ;
:: omnidrive-set-velocity ( robotino v omega -- )
    robotino omnidrive-id>> v first2 omega
    OmniDrive_setVelocity throw-when-false 
    v omega <position> robotino (>>current-direction) ;

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

: surrounding-values ( calibration-table value -- keys )
    [ values dup rest zip ] [ [ swap first2 between? ] curry ] bi* find nip ;
: values>keys ( calibration-table keys -- distances )
    [ swap value-at ] with map ;
: calc-barycentre ( a b c -- x )
    rot [ - ] curry bi@ swap / ;
: barycentre ( a b x -- c )
    [ [ swap - ] dip * ] [ 2drop ] 3bi + ;
:: value>distance ( calibration-table value -- distance )
    calibration-table value surrounding-values :> surrounding-values
    calibration-table surrounding-values values>keys :> surrounding-keys
    surrounding-values first2 value calc-barycentre :> x
    surrounding-keys first2 x barycentre ;

: odometry-construct ( robotino -- ) 
    Odometry_construct >>odometry-id 
    [ odometry-id>> ] [ com-id>> ] bi 
    Odometry_setComId throw-when-false ;
: odometry-destroy ( robotino -- ) odometry-id>> Odometry_destroy throw-when-false ;
: odometry-x ( robotino -- x ) odometry-id>> Odometry_x ;
: odometry-y ( robotino -- y ) odometry-id>> Odometry_y ;
: odometry-xy ( robotino -- {x,y} ) [ odometry-x ] [ odometry-y ] bi 2array ;
: odometry-phi ( robotino -- phi ) odometry-id>> Odometry_phi ;
: odometry-position ( robotino -- position ) [ odometry-xy ] [ odometry-phi ] bi <position> ;
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


: <init-robotino> ( -- robotino )
  "137.194.64.6:8080"
!  "137.194.10.31:8080"
!  "127.0.0.1:8080"
    <button-robotino>
    {
        [ omnidrive-construct ]
        [ odometry-construct ]
        [ init-all-sensors ]
        [ odometry-reset ]
        [ ] 
    }
    cleave ;
