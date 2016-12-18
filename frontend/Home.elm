module Home exposing (page)

import Html.Events exposing (onClick)
import Html exposing (..)


renderUserMenu : Maybe T -> Html Msg
renderUserMenu user =
    case user of
        Nothing ->
            div []
                [ button [ onClick (Login { email = "Simon.Gausmann@Gausmann-Media.de" }) ] [ text "Login" ]
                ]

        Just user ->
            div []
                [ button [ onClick (Logout) ] [ text "Logout" ]
                , button [ onClick (NavigationAction ProfilePageTyp) ] [ text "my Profile" ]
                ]


page =
    { title = "Home"
    , needsUser = False
    , content =
        div []
            [ div [] [ text "this is the homepage" ]
            ]
    }
