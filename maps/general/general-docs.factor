! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: classes help.markup help.syntax kernel math sequences 
ui.gadgets ;
IN: factorino.maps.general

HELP: <map>
{ $values
    { "size" "a pair of " { $link integer } } { "class" class }
    { "map" "a map" }
}
{ $description "Creates a new map from the given class" } ;

HELP: all-obstacles
{ $values
    { "map" "a map" }
    { "obstacles" sequence }
}
{ $description "Outputs all the obstacles of the map." } ;

HELP: decay
{ $values
    { "map" "a map" }
}
{ $description "Decays all the obstacles in the map. The obstacle "
" weight is decreased and the obstacle is removed if it goes under "
" some level."} ;

HELP: decay-ij
{ $values
    { "{i,j}" "a pair of " { $link integer } } { "map" "a map" }
}
{ $description "Decays cell {i,j}" } ;

HELP: draw-map
{ $values
    { "gadget" gadget } { "map" "a map" }
}
{ $description "gadget is the gadget in which the map is display. It can"
" be useful for getting the screen map size." } ;

HELP: in-map?
{ $values
    { "{i,j}" "a pair of " { $link integer } } { "map" "a map" }
    { "?" boolean }
}
{ $description "Tests if a cell is in the map." } ;

HELP: init
{ $values
    { "size" "a pair of " { $link integer } } { "map" "a map" }
    { "map" "a map" }
}
{ $description "This generic word is called by the map constructor" } ;

HELP: map-size
{ $values
    { "map" "a map" }
    { "size" "a pair of " { $link integer } }
}
{ $description "Outputs the size of the map" } ;

HELP: neighbours
{ $values
    { "{i,j}" "a pair of " { $link integer } } { "map" "a map" }
    { "neighbours" sequence }
}
{ $description "Returns a sequence of reachable neighbours from {i,j}" } ;

HELP: random-unexplored
{ $values
    { "map" "a map" }
    { "pos" "a pair of " { $link integer } }
}
{ $description "Returns an unexplored cell of the map." } ;

HELP: set-obstacle
{ $values
    { "{i,j}" "a pair of " { $link integer } } { "map" "a map" } { "obstacle?" boolean }
}
{ $description "Increments the obstacle weight at {i,j}." } ;

HELP: set-state
{ $values
    { "state" integer } { "{i,j}" "a pair of " { $link integer } } { "map" "a map" }
}
{ $description "Stores the internal state." } ;

HELP: state
{ $values
    { "{i,j}" "a pair of " { $link integer } } { "map" "a map" }
    { "state" integer }
}
{ $description "Returns the internal state." } ;

HELP: toggle-obstacle
{ $values
    { "{i,j}" "a pair of " { $link integer } } { "map" "a map" }
}
{ $description "Toggles between free and obstacle." } ;

ARTICLE: "factorino.maps.general" "factorino.maps.general"
"The " { $vocab-link "factorino.maps.general" } " vocabulary defines"
" a protocol for maps:"
{ $subsections init neighbours set-state state all-obstacles draw-map 
 map-size random-unexplored }
;

ABOUT: "factorino.maps.general"
