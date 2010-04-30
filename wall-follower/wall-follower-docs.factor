! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax kernel quotations sequences
strings ;
IN: factorino.wall-follower

HELP: follow-test
{ $values
    { "address" string }
}
{ $description "The string describing the adress can only be an ipv4 adress (no host names including localhost) with an optionnal port, for example 10.0.0.1:8080. If not specified, the default port is 80. This is the port used by a real robotino. The robotino simulator uses port 8080." } ;

ARTICLE: "factorino.wall-follower" "factorino.wall-follower"
"The " { $vocab-link "factorino.wall-follower" } " vocabulary provides a simple wall-following algorithm." { $subsections follow-test }
;

ABOUT: "factorino.wall-follower"
