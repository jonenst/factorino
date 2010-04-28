! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel factorino.types factorino.maps.general ;
IN: factorino.driving

HELP: (go-to)
{ $values
    { "robotino" robotino } { "position" "a position" } { "the-map" "a map" }
    { "arrived?" boolean }
}
{ $description "Drives to a point using a given map. See factorino.maps.general." } ;

HELP: go-to
{ $values
    { "robotino" robotino } { "position" "a position" }
    { "arrived?" boolean }
}
{ $description "Drives to a destination avoiding obstacles." } ;

ARTICLE: "factorino.driving" "factorino.driving"
"The " { $vocab-link "factorino.driving" } " vocabulary uses path-finding and factorino.asserv to move the robotino and avoid obstacles."
{ $subsections (go-to) go-to }
;

ABOUT: "factorino.driving"
