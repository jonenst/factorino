! Copyright (C) 2010 Jon Harper.
! See http://factorcode.org/license.txt for BSD license.
USING: slides help.markup 
sequences kernel parser memoize 
namespaces factorino.bindings factorino.basics factorino.asserv factorino.driving factorino.explore factorino.maps factorino.sensor-calibration ;
IN: factorino.presentation


CONSTANT: factorino-slides {
    { $intro-slide
        { "Factorino : Programmation d'un robotino en Factor" 40 }
        { "Implémentation d'un algorithme de SLAM" 30 }
    }
    { $slide "Plan"
        "Présentation de la plateforme"
        "Présentation du projet"
        "Présentation des différentes couches"
        "Conclusion"
    }
    { $slide "Présentation de la plate-forme"
        "Carte Geode + Linux temps réél"
        "Module Wifi"
        "Capteurs SHARPs"
        "Webcam"
        "Robot holonome"
        "Bibliothèque d'accès aux drivers assez haut niveau"
        "Robot pédagogique principalement pour éviter des obstacles.."
        "Mais aussi pour jouer au Hockey !"
    }
    { $slide "Présentation du projet" 
        "SLAM : Simultaneous localization and mapping"
        "Objectif: Cartographie et déplacements autour d'obstacles"
        "Plus généralement, des fonctions de controle de haut-niveau en Factor"
    }
    { $slide "L'implémentation"
        "Une série de couches (vocabulaires)"
        { "Qu'on peut découvrir avec la documentation de Factor : " { $link "factorino" } }
    }
      { $slide "Factorino.basics"
       
       { "Documentation : " { $link "factorino.basics" } } 
       { "Créer un objet robotino :" { $code "USE: factorino.basics <init-robotino>" } }
       { "Controler les moteurs :" 
            { $list { $code "dup { 50 50 } 30 omnidrive-set-velocity" }
                    { $code "dup { 0 0 } 0 omnidrive-set-velocity" }
            }
       }
       { "Obtenir les valeurs des sharps :" { $code "dup sensors-values ." } }
       { "Et l'odometrie, la camera, la vitesse instantanée . . ."  }
    }
    { $slide "Factorino.asserv"
       { "Documentation : " { $link "factorino.asserv" } } 
       { "Basé sur " { $link "factorino.basics" } }
       { "Déplacer le robot avec un asservissement en position :" 
           { $list 
           { $code "dup [ odometry-reset ] [ { 300 0 } drive-to ] bi ." } 
           { $code "dup { -300 0 } drive-from-here ." } 
            }
       }
       "Arret lorsqu'on s'approche d'un obstacle ou lors d'un choc"
       "Courbe de vitesse en trapèze pour éviter les glissements"
    }
    { $slide "Factorino.driving"
       { "Documentation : " { $link "factorino.asserv" } } 
       { "Basé sur " { $link "factorino.asserv" } ", " { $link "path-finding" } " et " { $link "factorino.maps" } }
       "Utiliser une carte pour noter les obstacles, et A* pour naviguer d'un point A à un point B"
       { $code "dup [ odometry-reset ] [ { 800 0 } go-to ] bi ." } 
    }
    { $slide "Factorino.explore"
        { "Documentation : " { $link "factorino.explore" } }
        { "Basé sur : " { $link "factorino.driving" } }
        { $code "dup test-explore" }
    }
    { $slide "Conclusion"
        { "Pas de correction de l'odométrie. Les pistes étaient :" 
            { $list "Les capteurs SHARPs" "La carte IMU" "La webcam" } 
        }
        { "Très vulnérables aux petits chocs qui ne déclenchent pas le bumper" }
        { "Projet peut-être trop ambitieux ? Ex: NorthStar" }
    }
    { $slide "Bonus"
        { $link "factorino.controller" }
        { $vocab-link "factorino.imu" }
        { $vocab-link "factorino.sensor-calibration" }
        }
}


 

: factorino-presentation ( -- ) "Jon Harper" presenter-name [ factorino-slides slides-window ] with-variable ;

MAIN: factorino-presentation
