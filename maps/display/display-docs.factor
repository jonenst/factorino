! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ui.gadgets factorino.types math ;
IN: factorino.maps.display

HELP: display
{ $values
    { "map" "a map" }
    { "map-gadget" gadget }
}
{ $description "Outputs a map-gadget that can be used to display the map. The map gadget will delegate all calls to the underlying map and should be used in place of the map." } ;

HELP: register-robotino
{ $values
    { "robotino" robotino } { "map-gadget" gadget }
}
{ $description "Register a robotino to a map-gadget. This allows position update on the map." } ;

HELP: update-current-path
{ $values
    { "map" "a map" } { "path" "a pathname string" }
}
{ $description "Update the current-path of the robotino. This is useful for debugging and pretty animations." } ;

HELP: update-robotino-position
{ $values
    { "map" "a map" } { "pos" "a pair of " { $link integer } }
}
{ $description "Update the current position of the robotino. This is useful for debugging and pretty animations. This should not be called, use " { $link register-robotino } " instead." } ;

ARTICLE: "factorino.maps.display" "factorino.maps.display"
"The " { $vocab-link "factorino.maps.display" } " implements a gadget"
" that lets you display maps in windows."
;

ABOUT: "factorino.maps.display"
