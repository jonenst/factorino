! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms assocs arrays byte-arrays calendar combinators
combinators.short-circuit delegate kernel locals math
math.constants math.functions math.order math.vectors models
namespaces prettyprint sequences system threads factorino.imu
factorino.bindings factorino.functor factorino.types factorino.utils ui ui.gadgets.buttons strings 
io.encodings.ascii fry io.sockets continuations 
io.binary ;
IN: factorino.basics
<PRIVATE
: surrounding-values ( calibration-table value -- values )
    {
        { [ 2dup [ values first ] dip > ] [ drop values 2 head ] }
        { [ 2dup [ values last ] dip < ] [ drop values 2 tail* ] }
        [ [ values dup rest zip ] [ [ swap first2 between? ] curry ] bi* find nip ]
    } cond ;
: values>keys ( calibration-table values -- distances )
    [ swap value-at ] with map ;
PRIVATE>
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
ROBOTINO-WORD: camera Camera
ROBOTINO-WORD: sensors DistanceSensor
M: array sensors-destroy* [ sensors-destroy* ] each ;

: num-distance-sensors ( -- n ) numDistanceSensors ; 

M: integer com-connect* Com_connect throw-when-false ; 
M: integer com-disconnect* Com_disconnect throw-when-false ; 
M: integer com-destroy* Com_destroy throw-when-false ;
M: integer com-wait-for-update* Com_waitForUpdate throw-when-false ;
M: integer com-address* 
    256 dup <byte-array>
    [ swap Com_address throw-when-false ] keep [ 0 = not ] filter >string ;
M: integer com-set-address* swap Com_setAddress throw-when-false ;

: omnidrive-construct ( robotino -- ) 
    T{ position f { 0 0 } 0 } >>current-direction
    OmniDrive_construct >>omnidrive-id
    [ omnidrive-id>> ] [ com-id>> ] bi
    OmniDrive_setComId throw-when-false ;
: omnidrive-destroy ( robotino -- ) omnidrive-id>> OmniDrive_destroy throw-when-false ;
:: omnidrive-set-velocity ( robotino v omega -- )
    robotino omnidrive-id>> v first2 omega
    [ OmniDrive_setVelocity ] curry 3curry :> the-function
    the-function call FALSE = [ 20 milliseconds sleep the-function call ] [ TRUE ] if
    throw-when-false 
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

:: value>distance ( calibration-table value -- distance )
    calibration-table value surrounding-values :> surrounding-values
    calibration-table surrounding-values values>keys :> surrounding-keys
    surrounding-values first2 value calc-barycentre :> x
    surrounding-keys first2 x barycentre ;
: sensors-distances ( robotino -- distances )
    [ calibration-table>> ] [ sensors-values ] bi
    over [ [ value>distance ] with map ] [ 2drop f ] if ;

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
: filtered-phi ( robotino -- phi ) odometry-phi ;
: filtered-xy ( robotino -- phi ) odometry-xy ;
: filtered-position ( robotino -- phi ) [ filtered-xy ] [ filtered-phi ] bi <position> ;
: (odometry-set) ( robotino x y phi -- ) [ odometry-id>> ] 3dip Odometry_set throw-when-false ;
: odometry-set ( robotino {x,y,phi} -- ) first3 (odometry-set) ;
: odometry-set-phi ( robotino phi -- ) [ dup odometry-xy first2 ] dip (odometry-set) ;
: odometry-reset ( robotino -- ) { 0 0 0 } odometry-set ;

: camera-construct ( robotino -- )
    Camera_construct >>camera-id
    [ camera-id>> ] [ com-id>> ] bi Camera_setComId throw-when-false ;
: camera-set-streaming ( robotino ? -- )
    [ camera-id>> ] [ TRUE FALSE ? ] bi* Camera_setStreaming throw-when-false ;
: camera-grab? ( robotino -- ? )
    camera-id>> Camera_grab TRUE = t f ? ;
: camera-image-size ( robotino -- dim )
    camera-id>> 4 <byte-array> dup clone [ Camera_imageSize drop ]
    2keep [ le> ] bi@ 2array ;
:: camera-get-image ( robotino -- image/f dim/f )
    robotino camera-grab? [ 
    robotino [ camera-id>> ] [ camera-image-size ] bi
    product 3 * dup <byte-array> :> result 
    result swap
    4 <byte-array> dup clone [ Camera_getImage throw-when-false ] 2keep [ le> ] bi@ 2array
    result swap ] [ f f ] if ;
: new-robotino ( address class -- robotino ) 
    new
    num-distance-sensors f <array> >>sensors-id
    Com_construct >>com-id
    [ com-set-address* ]
    [ com-connect* ] 
    [ ] tri ;
: <robotino> ( address -- robotino ) 
    \ robotino new-robotino ;
: stop-position-refresh ( robotino -- )
    position-refresh-alarm>> [ cancel-alarm ] when* ;
: kill-robotino ( robotino -- )
    { 
        [ stop-position-refresh ]
        [ sensors-destroy* ]
        [ bumper-destroy* ]
        [ omnidrive-destroy* ]
        [ camera-destroy* ]
        [ com-destroy* ] 
    } cleave ;
: kill-button ( robotino -- button )
    "KILL ME!" swap [ kill-robotino drop ] curry <border-button> ;
: kill-window ( robotino -- )
    kill-button [ "kill-switch" open-window ] curry with-ui ;
: refresh-position ( robotino -- )
    [ odometry-position ] [ current-position>> ] bi set-model ;
: init-position-refresh ( robotino -- )
    [ dup odometry-position \ robotino-position-model new-model >>current-position drop ]
    [ [ refresh-position ] curry 200 milliseconds every ]
    [ (>>position-refresh-alarm) ] tri ;

CONSTANT: imu-port 54321
: (merge-imu) ( imu-angle robotino -- )
    [ odometry-phi 0.99 barycentre ] 
    [ ! swap odometry-set-phi
      (>>filtered-phi) 
    ] bi ;
: merge-imu ( imu-angle robotino -- )
    dup current-direction>> {x,y}>> norm 0 1 v~ [ (merge-imu) ] [ 2drop ] if ;
: update-phi-with-imu ( robotino -- )
    dup imu-angle>> odometry-set-phi ;
CONSTANT: IMU-FIFO-LENGTH 15
: store-imu ( imu-angle robotino -- )
    nip [ imu-angle>> ] keep [ dup length IMU-FIFO-LENGTH > [ rest ] when swap suffix ] with change-prev-imu-angle drop ;
: refresh-imu ( imu-angle robotino -- )
    over [ 
        [ store-imu ] [ (>>imu-angle) ] [ (merge-imu) ] 2tri 
    ] [
        2drop
    ] if ;
: (refresh-quotation) ( remote encoding robotino -- quot )
    '[ _ _  [ [
                imu-angle _ refresh-imu t 
            ] loop
        ] with-client
    ] ; inline
: refresh-quotation ( remote encoding robotino -- quot )
    [ [ (refresh-quotation) ] [ 2drop 2drop ] recover ] 3curry ; inline
: init-imu-refresh ( robotino -- )
    [ com-address* imu-port <inet> ascii ]
    [ refresh-quotation ]
    [  [ "imu-thread" spawn ] dip (>>imu-thread) ] tri ;
    
: <init-robotino> ( -- robotino )
!    "172.26.201.1"
!  "137.194.64.6:8080"
!  "137.194.10.31:8080"
  "137.194.66.211"
!  "127.0.0.1:8080"
   <robotino> 
    {
        [ omnidrive-construct ]
        [ odometry-construct ]
        [ camera-construct ]
        [ init-all-sensors ]
        [ odometry-reset ]
        [ init-position-refresh ]
        [ init-imu-refresh ] 
        [ ] 
    }
    cleave ;

: <button-robotino> ( -- robotino )
    <init-robotino> dup kill-window ;
<PRIVATE
: calc-angle ( previous-time -- angle current-time ) 
    nano-count [ - pi 2 * * 9 10 ^ / ] keep ;
:: (drive) ( robotino vector previous-time -- )
    previous-time calc-angle :> new-time :> angle
    vector angle rotate :> new-vector
    robotino new-vector 0 omnidrive-set-velocity
    50 milliseconds sleep 
    robotino new-vector new-time (drive) ; 
PRIVATE>
: drive ( robotino -- ) { 200 0 } nano-count (drive) ;
: robotino-test ( adress -- )
    <robotino> dup omnidrive-construct drive ; 
