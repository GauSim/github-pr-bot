module UserProfile exposing (page)

import Material.Card as Card
import Material.Options as Options
import Material.Options exposing (css)
import Material.Color as Color
import Html exposing (..)
import Routing exposing (..)


white =
    Color.text Color.white


page =
    { title = "Profile Page"
    , needsUser = True
    , content =
        Card.view
            [ css "width" "128px"
            , Color.background (Color.color Color.Pink Color.S500)
            ]
            [ Card.title [] [ Card.head [ white ] [ text "Hover here" ] ]
            , Card.text [ white ] [ text " clicks so far." ]
            , Card.actions [ Card.border, white ] [ text "(not here)" ]
            ]
    }
