! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: help.markup help.syntax ;
IN: factorino.controller

HELP: controller
{ $description "Opens a new window that can connect to a robotino." } ;

ARTICLE: "factorino.controller" "factorino.controller"
"The " { $vocab-link "factorino.controller" } " vocabulary allows "
" easy creation and connection of robotinos. It also displays the webcam"
" feed if available and warnings from the SHARPs sensors."
{ $subsections controller }
;

ABOUT: "factorino.controller"
