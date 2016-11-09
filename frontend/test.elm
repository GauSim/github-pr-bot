module Main exposing (..)

import Html exposing (Html, button, div, text, li, ul)
import Html.App as App
import Html.Events exposing (onClick)


main =
    App.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { count : Int
    , currentPage : Maybe Page
    , hasUser : Bool
    }


type alias Page =
    { pageType : PageType
    , title : String
    , needsUser : Bool
    }


model : Model
model =
    { count = 0, currentPage = List.head pages, hasUser = False }


pages : List Page
pages =
    [ { pageType = Home
      , title = "Home"
      , needsUser = False
      }
    , { pageType = About
      , title = "About"
      , needsUser = False
      }
    ]


type PageType
    = Home
    | About


type Msg
    = Change PageType
    | Login
    | Logout


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change Home ->
            { model | currentPage = tryAccess (forPage Home) model.hasUser }

        Change About ->
            { model | currentPage = tryAccess (forPage About) model.hasUser }

        Login ->
            { model | hasUser = True }

        Logout ->
            { model | hasUser = False, currentPage = tryAccess Nothing False }


tryAccess : Maybe Page -> Bool -> Maybe Page
tryAccess page hasUser =
    if hasUser then
        page
    else
        forPage Home


forPage : PageType -> Maybe Page
forPage pageType =
    List.head (List.filter (\page -> (page.pageType == pageType)) pages)


pageTitle : Maybe Page -> String
pageTitle currentPage =
    case currentPage of
        Nothing ->
            ""

        Just currentPage ->
            currentPage.title


renderMenu : List Page -> Html Msg
renderMenu pages =
    ul [] (List.map toMenuLink pages)


toMenuLink : Page -> Html Msg
toMenuLink page =
    li [] [ button [ onClick (Change page.pageType) ] [ text page.title ] ]


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text (toString model) ]
        , div [] [ (renderMenu pages) ]
        , button [ onClick (Login) ] [ text "Login" ]
        , button [ onClick (Logout) ] [ text "Logout" ]
        , div []
            [ text (pageTitle model.currentPage) ]
        ]
