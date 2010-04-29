USING: help.markup help.syntax kernel
factorino.asserv factorino.driving factorino.explore factorino.maps factorino.sensor-calibration ;
IN: factorino

ARTICLE: "factorino" "Factorino"
"The " { $vocab-link "factorino" } " vocabulary groups all vocabularies dealing with the Robotino. For more information, see " { $url "http://www.festo-didactic.com/ch-fr/learning-systems/nouveau-robotino/" } "."
$nl
"Here are a few vocabularies to start with: "
{ $list { $link "factorino.types" } { $link "factorino.asserv" } { $link "factorino.driving" } { $link "factorino.explore" } { $link "factorino.maps" } { $link "factorino.sensor-calibration" } }

$nl
"The " { $vocab-link "factorino.wall-follower" } " implements a simple wall following algorithm, adapted from the example c++ code found on the robotino"
;

ABOUT: "factorino"
