! Copyright (C) 2010 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators combinators.short-circuit
factorino.basics factorino.types factorino.utils inverse io
kernel math math.constants math.vectors memoize prettyprint
sequences threads ;
IN: factorino.wall-follower

CONSTANT:  SLOW_VELOCITY 200 ! mm/s
CONSTANT:  MEDIUM_VELOCITY 300 ! mm/s
CONSTANT:  VELOCITY 400 ! mm/s
CONSTANT:  FAST_VELOCITY 480 ! mm/s
CONSTANT:  ANGULARVELOCITY 5.0 ! deg/s

CONSTANT: ESCAPE_V 2.2
CONSTANT: WALL_LOST_V 0.9
CONSTANT: WALL_FOUND_V 1.1
CONSTANT: WALL_FOLLOW_V 1.7
CONSTANT: NEW_WALL_FOUND_V 1.9

TUPLE: wall-follower < robotino current-wall-sensor current-dir velocity rot-velocity ;

: to-degrees ( radian -- degrees ) 180 * pi / ;
: to-radian ( degrees -- radian ) [ to-degrees ] undo ;

: index-of-supremum  ( seq -- n ) [ supremum ] keep index ;
: biggest-sensor ( robotino -- n ) sensors-values index-of-supremum ;
: biggest-sensor-value ( robotino -- val ) sensors-values supremum ;
: sensors-on-wall ( robotino -- n ) sensors-values [ ESCAPE_V > ] filter length ;
MEMO: escape-vectors  ( robotino -- vectors ) sensors-headings [ { 1 0 } swap to-radian rotate ] map ;
: current-escape-vector ( robotino -- vector ) 
    [ current-wall-sensor>> ] [ escape-vectors ] bi nth ;

: scaled-sum ( sensor-values vectors -- sum-vector )
    [ over ESCAPE_V > [ n*v ] [ 2drop { 0 0 } ] if ] [ v+ ] 2map-reduce ;
: wall-distance ( robotino -- voltage ) 
    [ current-wall-sensor>> ] keep distance-sensor-voltage ;
: escape-vector ( robotino -- v )
    [ sensors-values ] [ escape-vectors ] bi scaled-sum
    normalize 
    pi rotate ; 
: calc-store-escape-vector ( robotino -- )
    [ escape-vector ] keep (>>current-dir) ;

: new-wall? ( robotino -- ? )
    { [ biggest-sensor-value NEW_WALL_FOUND_V > ]
      [ [ biggest-sensor ] [ current-wall-sensor>> ] bi = not ] } 1&& ;
: update-new-wall ( robotino -- updated? )
    dup new-wall? [ [ 
            dup biggest-sensor >>current-wall-sensor drop
        ] [ drop ] if 
    ] keep ;
    
: wall-lost ( robotino -- ) 
        f >>current-wall-sensor
        [ -20 to-radian rotate ] change-current-dir
        -20 to-radian >>rot-velocity drop ;
: other-sensor-index ( robotino quot -- index ) 
    [ current-wall-sensor>> ] dip call num-distance-sensors rem ; inline
: next-neighbour-index ( robotino -- index )
    [ 1 + ] other-sensor-index ;
: prev-neighbour-index ( robotino -- index )
    [ 1 - ] other-sensor-index ;
: neighbour-value ( robotino -- value ) 
    [ next-neighbour-index ] keep distance-sensor-voltage ;
: check-neighbour-sensor ( robotino -- )
    dup
    [ neighbour-value  ]
    [ wall-distance ] bi > [
        "next plus proche" print
       dup next-neighbour-index >>current-wall-sensor
    ] when drop ;
: do-check ( id robotino -- ) 
    2dup distance-sensor-voltage WALL_FOUND_V > [
        swap >>current-wall-sensor
        SLOW_VELOCITY >>velocity
        "en face plus proche" print
    ] [ nip ] if drop ;
: forward-sensors ( robotino -- seq )
    current-wall-sensor>> 2 iota [ + 2 + num-distance-sensors mod ] with map ;
: check-forward-sensors ( robotino -- )
    [ forward-sensors ] keep [ do-check ] curry each ;

: neighbours-rot-velocity ( robotino -- velocity )
    [ [ next-neighbour-index ] [ prev-neighbour-index ] bi ] keep
    [ distance-sensor-voltage ] curry bi@ - ;
: new-dir ( robotino followAngle -- dir )
    [ current-escape-vector ] dip rotate ;
: update-dir ( robotino followAngle -- )
    dupd new-dir >>current-dir drop ;
: update-rot-velocity ( robotino velocity -- robotino )
    8 * ANGULARVELOCITY * >>rot-velocity ;
: toto ( robotino velocity -- follow-angle ) 
    [ update-rot-velocity ] keep
    abs {
        { [ dup 0.9 > ] 
          [ [ SLOW_VELOCITY >>velocity ]
            [ 0 > 140 80 ? ] bi* ] }
        { [ dup 0.4 > ] 
          [ [ MEDIUM_VELOCITY >>velocity ] 
            [ 0 > 120 85 ? ] bi* ] }
        [ drop 95 ]
    } cond to-radian nip ;
 

: balance-neighbours ( robotino -- ) 
    dup dup neighbours-rot-velocity toto update-dir ;
: scale-factor ( robotino -- baba ) 
    wall-distance WALL_FOLLOW_V swap - dup 0 > [ 0.2 * ] when ;
: keep-wall-distance ( robotino -- )
    dup dup balance-neighbours [ scale-factor ] [ current-escape-vector ] bi
    [ n*v v+ normalize ] 2curry change-current-dir drop ;
  

: current-sensor-valid ( robotino -- )
    dup wall-distance dup "walldist : " print . WALL_LOST_V < [
        "wall-lost" print
        wall-lost
    ] [
        dup dup update-new-wall [
            "updated" print
            SLOW_VELOCITY >>velocity drop
        ] [ 
            "still same wall" print
           [ check-neighbour-sensor ]
           [ check-forward-sensors ] bi
        ] if
        keep-wall-distance
    ] if ; 
 
: current-sensor-invalid ( robotino -- )
    dup biggest-sensor-value WALL_FOUND_V > [
        dup biggest-sensor >>current-wall-sensor
        SLOW_VELOCITY >>velocity
    ] when drop ;
: follow-wall ( robotino -- )
    dup current-wall-sensor>> [
        "valid" print
        current-sensor-valid
        ] [
        "invalid" print
        current-sensor-invalid
    ] if ;
: calc-speed ( robotino -- )
    dup sensors-on-wall 2 >= [
        "escaping !!" print
        [ calc-store-escape-vector ]
        [ SLOW_VELOCITY >>velocity ANGULARVELOCITY >>rot-velocity drop ] bi
    ] [
        follow-wall 
    ] if ;
: speedup ( robotino -- ) 
    dup biggest-sensor-value 0.9 < [
        FAST_VELOCITY >>velocity 
    ] when drop ;
: apply-new-velocity ( robotino -- )
    dup [ [ current-dir>> dup "Dir is now : " write . ] [ velocity>> ] bi v*n ] [ rot-velocity>> ] bi omnidrive-set-velocity ;
: drive ( robotino -- )
    VELOCITY >>velocity
    [ [ calc-speed ] [ speedup ] [ apply-new-velocity ] tri ] keep 
    50 milliseconds sleep drive ;

: follow-test ( address -- )
    wall-follower new-robotino
    { 1 0 } >>current-dir 0 >>rot-velocity 
    [ omnidrive-construct ] [ init-all-sensors ] [ drive ] tri ;


