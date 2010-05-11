! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays calendar combinators.short-circuit
factorino.basics factorino.types factorino.utils io kernel math math.order math.vectors
prettyprint threads sequences locals math.functions factorino.imu assocs ;
FROM: factorino.types.private => fix-angle ;
IN: factorino.asserv

<PRIVATE

CONSTANT: merge-factor 0.8
: (merge-vectors) ( to-position previous-dir -- result )
    [ [ merge-factor barycentre ] 2map ] when* ;
: angular-distance ( a1 a2 -- distance )
    [ - ] [ swap - ] 2bi [ 360 rem ] bi@ min ;
PRIVATE>
CONSTANT: SPEED-MULTIPLIER 2
CONSTANT: OMEGA-MULTIPLIER 10
CONSTANT: STOP-SPEED 20 ! mm/sec ??
CONSTANT: MAXIMUM-SPEED 200 ! mm/sec ??
CONSTANT: MINIMUM-SPEED 10 ! mm/sec ??
CONSTANT: MAXIMUM-ROTATION 20 ! mm/sec ??
CONSTANT: MINIMUM-ROTATION 3 ! mm/sec ??
CONSTANT: XY-THRESHOLD 10 ! mm ??
CONSTANT: PHI-THRESHOLD 1 ! degrees
CONSTANT: OBSTACLE_THRESHOLD 1.5 



: wait-few-updates ( robotino -- )
    yield
    [ com-wait-for-update* ] curry 3 swap times ;

<PRIVATE
: to-position-speed ( norm -- speed )
    SPEED-MULTIPLIER * MINIMUM-SPEED MAXIMUM-SPEED clamp ;

: to-position-vector ( robotino position -- vector )
    swap
    [ [ {x,y}>> ] [ filtered-xy ] bi* v- ]
    [ nip filtered-phi neg ] 2bi
    rotate-degrees ;

: to-position-speed-vector ( robotino position -- speed-vector )
    [ to-position-vector [ normalize ] [ norm ] bi 
    dup zero? [ 2drop { 0 0 } ] [ to-position-speed v*n ] if ]
    [ drop current-direction>> {x,y}>> ] 2bi (merge-vectors) ;

: fit-to-range ( omega -- omega )
    [ abs MINIMUM-ROTATION MAXIMUM-ROTATION clamp ] keep sgn * ;
: adjust-current ( goal current -- goal current )
    2dup > [ 360 + ] [ 360 - ] if ;
: chose-side ( goal current -- omega )
    2dup - abs 180 > [ 
    adjust-current
    ] when - ;
: ((to-position-omega)) ( current destination -- omega )
    ! 2dup [ "at : " write . ] [ "going to : " write . ] bi*
    swap chose-side OMEGA-MULTIPLIER * 
    fit-to-range ;
: (to-position-omega) ( robotino phi -- omega )
    [ filtered-phi ] [ ] bi* ((to-position-omega)) ;

: to-position-omega ( robotino position -- omega )
    dup phi>> [
        phi>> (to-position-omega)
    ] [
        over initial-angle>> [
            drop dup initial-angle>> (to-position-omega)
        ] [
            drop current-direction>> phi>>  
        ] if
    ] if ;

: go-position ( robotino position -- current-dir )
    [ drop ] [ to-position-speed-vector ] [ to-position-omega ] 2tri
    [ omnidrive-set-velocity ] 2keep drop ;

: xy-at-position? ( robotino position -- ? ) 
    dup {x,y}>> [ 
        [ filtered-xy ] [ {x,y}>> ] bi* v- norm XY-THRESHOLD <
    ] [ 
        2drop t 
    ] if ;
: ((theta-at-position?)) ( phi theta -- ? )
    ! 2dup [ "at : " write . ] [ "going to : " write . ] bi*
    dup [  
        angular-distance PHI-THRESHOLD <
    ] [
        2drop t
    ] if ;

: (theta-at-position?) ( robotino phi -- ? )
    [ filtered-phi ] dip ((theta-at-position?)) ;
: theta-at-position? ( robotino position -- ? )
    phi>> (theta-at-position?) ;
: imu-stable ( robotino -- ? )
    [ imu-angle>> ] [ prev-imu-angle>> ] bi dup .
    [ 0.5 ~ ] with all? 
    dup [ "imu unstable !!" print ] unless 
    yield 
    ;
: low-speed? ( robotino -- ? )
    current-direction>> [ {x,y}>> norm STOP-SPEED < ] [ t ] if* ;
: at-position? ( robotino position -- ? )
    { [ xy-at-position? ] [ theta-at-position? ] 
    ! [ drop low-speed? ]
    } 2&& ;

: stop-robotino ( robotino -- ) [ { 0 0 } 0 omnidrive-set-velocity ] [ f >>initial-angle drop ] bi ;

: print-position ( robotino -- robotino )
    [ [ filtered-xy ] [ filtered-phi ] bi "Position : " . . . ] keep ;
:: >padding ( direction -- padding ) 
    direction norm :> r
    r zero? [ f ] [
        direction first2 :> ( x y )
        { [ y zero? ] [ x 0 < ] } 0&& [
            180
        ] [
            y x r + / atan 2 * to-degrees 
        ] if
    ] if ;
: calc-initial-angle ( robotino position -- angle )
    swap filtered-xy v- >padding ;
: assign-initial-angle ( robotino position -- )
    dupd calc-initial-angle >>initial-angle drop ;
CONSTANT: FRONT-RANGE 45
: front-range ( padding -- range ) 
    FRONT-RANGE [ - ] [ + ] 2bi 2array ;
: in-range ( angle range -- ? ) 
    [ 360 [ + ] [ - ] [ drop ] 2tri ] dip
    [ first2 between? ] curry tri@ or or ;
: front-indices ( robotino range -- indices )
    [ sensors-headings ] dip 
    [ swapd in-range [ drop f ] unless ] curry map-index sift ;
: values-in-range ( robotino range -- values ) 
    dupd front-indices swap [ distance-sensor-voltage ] curry map ;
: against-obstacle? ( robotino current-direction -- ? )
    >padding dup [ front-range values-in-range
    supremum OBSTACLE_THRESHOLD > ] [ nip ] if ;
DEFER: drive-position
: continue-driving ( stop? robotino position -- blocking-pos/f )
    2dup at-position? [
        drop swap [ stop-robotino ] [ drop ] if f yield
    ] [
        drive-position
    ] if ;
: moving? ( robotino -- ? )
    measured-speed>> MOVING-THRESHOLD > ;
SINGLETON: +obstacle-seen+
SINGLETON: +hard-block+
: block-condition ( robotino current-dir -- block-info/f )
    over { [ should-be-moving?>> ] [ moving? not ] } 1&& [ 2drop +hard-block+ ] [
        2dup against-obstacle? [ 2drop +obstacle-seen+ ] [ 2drop f ] if
    ] if ;
:: drive-position ( stop? robotino position -- blocking-pos/f )
    robotino position go-position :> current-dir
    robotino current-dir block-condition [
        robotino stop-robotino
        +hard-block+ = [ 1.5 seconds sleep ] when
        position
    ] [
        robotino com-wait-for-update*
        ! WTF, com-wait-for-update* is blocking !! 
        yield
        stop? robotino position continue-driving
    ] if* ;

: drive-xy ( stop? robotino {x,y} -- blocking-position/f )
    f <position> drive-position ;

GENERIC: drive-to* ( stop? robotino destination -- blocking-position/f )
:: drive-path* ( quot: ( -- ) stop? robotino path -- blocking-position/f )
    quot call( -- )
    path empty? [
        stop? [ robotino stop-robotino ] when f
    ] [
        path unclip :> ( rest first ) 
            f robotino first drive-to* :> blocking-pos/f
            blocking-pos/f [ 
               blocking-pos/f
            ] [ 
              quot stop? robotino rest drive-path*
            ] if 
    ] if ;
: drive-path ( stop? robotino path -- blocking-position/f )
[ [ ] ] 3dip drive-path* ;
PRIVATE> 
: (rotate-to) ( robotino phi -- )
    "rotate-to" print yield
    [ [ imu-angle>> ] [ fix-angle ] bi* ((to-position-omega)) ]
    [ drop swap [ { 0 0 } ] dip yield omnidrive-set-velocity ]
    [ 2dup { [ [ imu-angle>> ] dip ((theta-at-position?)) ] [ drop imu-stable ] } 2&&
        [ drop stop-robotino ] [ (rotate-to) ] if
    ] 2tri ;
: rotate-to ( robotino phi -- )
    [ (rotate-to) ] [ drop update-phi-with-imu ] 2bi ;
: rotate-from-here ( robotino phi -- )
    [ dup imu-angle>> ] dip + rotate-to ;
<PRIVATE
: face-initial-angle ( robotino -- )
    dup initial-angle>> rotate-to ;
M: 2d-point drive-to*
    [ drive-xy ] call ;
M: array drive-to* drive-path ;
M: position drive-to* drive-position ;

PRIVATE>
: drive-to ( robotino destination -- blocking-position/f )
    [ t ] 2dip drive-to* ;
: drive-origin ( robotino -- blocking-position/f )
    [ t ] dip T{ position f { 0 0 } 0 } drive-position ;
<PRIVATE
GENERIC# change-base 1 ( destination base -- new-destinations )
M: 2d-point change-base [ nip {x,y}>> ] [ phi>> to-radian rotate ] 2bi v+ ;
M: array change-base [ change-base ] curry map ;
M: position change-base [ [ {x,y}>> ] dip change-base ] [ [ phi>> ] bi@ + ] 2bi <position> ;
PRIVATE>
! All destinations in initial base
: from-robotino-base ( robotino destination -- robotino new-destinations )
    over odometry-position change-base ;
: drive-from-here ( robotino destination -- blocking-pos/f )
    from-robotino-base drive-to ;
! All relative destinations
GENERIC: drive-from-here* ( robotino destination -- blocking-pos/f )
M: position drive-from-here* drive-from-here ;
M: 2d-point drive-from-here* drive-from-here ;
M: array drive-from-here*
    [ drop f ]
    [ unclip pick swap drive-from-here* [ 2nip ] [ drive-from-here ] if* ] if-empty ;

: drive-execute-path ( quot: ( -- ) robotino path -- blocking-pos/f ) [ f ] 2dip drive-path* ;


: seen-obstacles ( robotino -- angles ) 
    [ sensors-values ] [ sensors-headings ] bi
    zip [ first OBSTACLE_THRESHOLD < ] filter values ;
    
