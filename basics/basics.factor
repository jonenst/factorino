! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alarms assocs arrays byte-arrays calendar combinators
combinators.short-circuit delegate kernel locals math
math.constants math.functions math.order math.vectors models
namespaces prettyprint sequences system threads factorino.imu
factorino.bindings factorino.functor factorino.types factorino.types.utils factorino.utils ui ui.gadgets.buttons strings 
io.encodings.ascii fry io.sockets continuations 
io.binary images tools.time io images.viewer ;
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
M: integer com-wait-for-update* drop 50 milliseconds sleep ;
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
: try-n-times ( function n -- BOOL )
    dup zero? [ 2drop FALSE ] [
        over call( -- x ) TRUE = [ 2drop TRUE ] [ 1 - 10 milliseconds sleep try-n-times ] if
    ]  if ; inline recursive 
: 4curry ( a b c d quot -- quot ) 2curry 2curry ;

! TODO: check that we're moving in the right direction to catch partial blocks ? Does this happen ?
CONSTANT: MOVING-THRESHOLD 1
: ?set-later ( robotino -- )
    dup should-be-moving-alarm>> [
        drop
    ] [
        [ [ t >>should-be-moving? ] curry 500 milliseconds later ] keep (>>should-be-moving-alarm)
    ] if ;
: cancel-set ( robotino -- )
    [ should-be-moving-alarm>> [ cancel-alarm "alarm canceled" print ] when* ]
    [ f >>should-be-moving-alarm f >>should-be-moving? drop ] bi ;
: set-should-be-moving ( robotino v -- )
    norm MOVING-THRESHOLD > [ ?set-later ] [ cancel-set ] if ;
:: omnidrive-set-velocity ( robotino v omega -- )
    robotino omnidrive-id>> v first2 omega
    [ OmniDrive_setVelocity ] 4curry 3 try-n-times throw-when-false 
    v omega <position> robotino (>>current-direction)
    robotino v set-should-be-moving ;

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
: odometry-set ( robotino position -- ) [ {x,y}>> first2 ] [ phi>> ] bi (odometry-set) ;
: odometry-set-phi ( robotino phi -- ) [ dup odometry-xy first2 ] dip (odometry-set) ;
: odometry-reset ( robotino -- ) dup raw-imu>> >>imu-offset  { 0 0 } 0 <position> odometry-set ;

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
:: (camera-get-image) ( robotino byte-array -- )
    robotino camera-id>> byte-array dup length
    4 <byte-array> dup clone Camera_getImage throw-when-false ;
: camera-get-image* ( robotino byte-array -- )
        (camera-get-image) ;
:: camera-get-image ( robotino -- image/f dim/f )
    robotino dup camera-image-size [ product 3 * <byte-array> 
        [ (camera-get-image) ] keep ] keep ;

: camera-grab-image ( robotino -- image/f dim/f )
    dup camera-grab? [ 
        camera-get-image
    ] [
        drop f f ] if ;
: camera-grab-image* ( robotino byte-array -- )
    over camera-grab? [ 
        camera-get-image*
    ] [ 2drop ] if ;
: new-image-needed? ( robotino -- ? )
   [ camera-image>> value>> dim>> ] [ camera-image-size ] bi = not ;
: (update-image) ( robotino -- )
    dup new-image-needed?
    [
        [ camera-get-image <robotino-image> ] [ camera-image>> ] bi set-model
    ] [
        dup camera-image>> 
            [ value>> bitmap>> camera-get-image* ]
            [ notify-connections ] bi
    ]
    if ;
: update-image ( camera-gadget -- )
    dup camera-grab? [ (update-image) ] [ drop ] if ;
: camera-start-refreshing ( robotino -- )
    [ t camera-set-streaming ]
    [ [ [ update-image ] curry 1 15 / seconds every ] keep (>>camera-alarm) ] bi ;
: camera-stop-refreshing ( gadget -- )
    [ [ f camera-set-streaming ] curry [ drop ] recover ]
    [ camera-alarm>> [ cancel-alarm ] when* ] bi ;
: camera-start/stop ( robotino -- )
    dup observers>> empty? [ camera-stop-refreshing ] [ camera-start-refreshing ] if ;
: (set-camera-observer) ( observer robotino connection-quot observers-quot -- )
     '[ [ camera-image>> @ ] [  _ with change-observers camera-start/stop ] 2bi ] call ; inline 
: register-camera-observer ( observer robotino -- )
    [ [ add-connection ] [ set-image ] 2bi drop ] [ swap suffix ] (set-camera-observer) ;
: unregister-camera-observer ( observer robotino -- )
    [ remove-connection ] [ remove ] (set-camera-observer) ;

: new-robotino ( address class -- robotino ) 
    new
    num-distance-sensors f <array> >>sensors-id
    Com_construct >>com-id
    [ com-set-address* ]
    [ com-connect* ] 
    [ ] tri
    { } clone { 0 0 } <robotino-image> <model> >>camera-image
    { } \ robotino-path-model new-model >>current-path
    ;
: <robotino> ( address -- robotino ) 
    \ robotino new-robotino ;
: stop-position-refresh ( robotino -- )
    position-refresh-alarm>> [ cancel-alarm ] when* ;
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
CONSTANT: IMU-FIFO-LENGTH 30
: store-imu ( robotino -- )
    [ imu-angle>> ] keep [ dup length IMU-FIFO-LENGTH > [ rest ] when swap suffix ] with change-prev-imu-angle drop ;
: refresh-imu ( imu-angle robotino -- )
    over [ 
        { [ nip store-imu ] [ [ imu-offset>> - ] keep (>>imu-angle) ] [ (merge-imu) ]
        [ (>>raw-imu) ] } 2cleave 
    ] [
        2drop
    ] if ;
: (refresh-quotation) ( remote encoding robotino -- quot )
    '[ _ _  [ [
                imu-angle _ [ refresh-imu ] [ refresh-imu?>> ] bi
            ] loop
        ] with-client
    ] ; inline
: refresh-quotation ( remote encoding robotino -- quot )
    [ [ (refresh-quotation) call ] [ [ 3drop ] dip "imu failed for some reason" debug drop drop ] recover ] 3curry ; inline
: init-imu-refresh ( robotino -- )
    [ com-address* imu-port <inet> ascii ]
    [ refresh-quotation ]
    [  [ "imu-thread" spawn ] dip (>>imu-thread) ] tri ;
: stop-imu-refresh ( robotino -- )
    f >>refresh-imu? drop ;
: calc-speed ( robotino -- speed )
    [ 
        [ filtered-xy 
          50 milliseconds sleep ]
        [ filtered-xy ] bi 
    ] benchmark 9 10^ /
    [ v- norm ] dip / ;
: refresh-speed ( robotino -- ) [ calc-speed ] [ (>>measured-speed) ] bi ;
: refresh-speed-loop ( robotino -- )
    [ [ refresh-speed ] [ measure-speed?>> ] bi ] curry loop ;

: init-refresh-speed ( robotino -- )
    [ [ refresh-speed-loop ] curry "refreshing speed thread" spawn ] keep (>>measure-speed-alarm) ;
: stop-refresh-speed ( robotino -- )
   f >>measure-speed? drop ; 

: kill-robotino ( robotino -- )
    { 
        [ stop-position-refresh ]
        [ stop-refresh-speed ]
        [ stop-imu-refresh ]
        [ camera-stop-refreshing ]
        [ sensors-destroy* ]
        [ bumper-destroy* ]
        [ omnidrive-destroy* ]
        [ com-destroy* ] 
    } cleave ;
: kill-button ( robotino -- button )
    "KILL ME!" swap [ kill-robotino drop ] curry <border-button> ;
: kill-window ( robotino -- )
    kill-button [ "kill-switch" open-window ] curry with-ui ;
   
: <init-robotino> ( -- robotino )
    "172.26.201.1"
!  "137.194.64.6:8080"
!  "137.194.10.31:8080"
!  "137.194.66.211"
!  "127.0.0.1:8080"
   <robotino> 
    {
        [ omnidrive-construct ]
        [ odometry-construct ]
        [ camera-construct ]
        [ init-all-sensors ]
        [ odometry-reset ]
        [ init-position-refresh ]
        [ init-refresh-speed ]
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
