! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel ;
IN: factorino.types

HELP: 2d-point
{ $var-description "Represents a x,y point in space without any angle information" } ;

HELP: <position>
{ $values
    { "{x,y}" 2d-point } { "phi" real }
    { "position" position }
}
{ $description "User code should never user raw position objects. Instead, build them with this constructor." } ;

HELP: position
{ $var-description "Represents a x,y point in space with angle phi" } ;

HELP: robotino
{ $var-description "Represents a robotino. Stores information to communicate with the C library and to do basic navigation." } ;

HELP: robotino-position-model
{ $var-description "" } ;

HELP: throw-when-false
{ $values
    { "return-code" BOOL }
}
{ $description "Throws an exception if the return code from the library is FALSE" } ;
ARTICLE: "destination" "destination"
"A destination is either a " { $instance 2d-point } ", a " { $instance position } " tuple or an array of destinations."
;
ARTICLE: "factorino.types" "factorino.types"
"The " { $vocab-link "factorino.types" } " vocabulary regroups the different types used in all factorino vocabularies. Here are the most important types:"
{ $subsections robotino "destination" }
;

ABOUT: "factorino.types"
