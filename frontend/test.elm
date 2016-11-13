module Main exposing (..)

import Html exposing (Html, button, div, text, li, ul)
import Html.App as App
import Html.Events exposing (onClick)


main =
    App.beginnerProgram { model = init, view = view, update = update }



-- MODEL


type alias Model =
    { currentPage : Page
    , currentUser : Maybe User
    }


type alias Page =
    { pageType : PageType
    , title : String
    , needsUser : Bool
    , content : Html Msg
    }


type alias User =
    { email : String }


init : Model
init =
    { currentPage = (getPage HomePageTyp allPages), currentUser = Nothing }


allPages : List Page
allPages =
    [ { pageType = HomePageTyp
      , title = "Home"
      , needsUser = False
      , content = div [] [ text "this is the homepage" ]
      }
    , { pageType = AboutPageTyp
      , title = "About"
      , needsUser = True
      , content = div [] []
      }
    , { pageType = ProfilePageTyp
      , title = "Welcome"
      , needsUser = True
      , content = div [] []
      }
    , { pageType = ErrorPageType
      , title = "404"
      , needsUser = False
      , content = div [] []
      }
    ]


dummyUser : User
dummyUser =
    { email = "Simon.Gausmann@Gausmann-Media.de" }



-- UPDATE


type PageType
    = HomePageTyp
    | AboutPageTyp
    | ProfilePageTyp
    | ErrorPageType


type Msg
    = NavigationAction PageType
    | Login User
    | Logout


update : Msg -> Model -> Model
update msg model =
    case msg of
        NavigationAction pageType ->
            { model | currentPage = (getPage pageType (getPagesForUser model.currentUser allPages)) }

        Login user ->
            { model | currentUser = Just user, currentPage = (getPage ProfilePageTyp allPages) }

        Logout ->
            { model | currentUser = Nothing, currentPage = (getPage HomePageTyp allPages) }


getPage : PageType -> List Page -> Page
getPage pageType pages =
    case List.head (List.filter (\page -> (page.pageType == pageType)) pages) of
        Nothing ->
            (getPage ErrorPageType allPages)

        Just page ->
            page


getPagesForUser : Maybe User -> List Page -> List Page
getPagesForUser user pages =
    case user of
        Nothing ->
            List.filter (\page -> page.needsUser == False && page.pageType /= ErrorPageType) pages

        _ ->
            List.filter (\page -> page.pageType /= ErrorPageType) pages



-- VIEW


renderUserMenu : Maybe User -> Html Msg
renderUserMenu user =
    div []
        [ button [ onClick (Login dummyUser) ] [ text "Login" ]
        , button [ onClick (Logout) ] [ text "Logout" ]
        ]


renderMainMenu : Maybe User -> List Page -> Html Msg
renderMainMenu currentUser pages =
    ul [] ((List.map renderMenuLink) (getPagesForUser currentUser pages))


renderMenuLink : Page -> Html Msg
renderMenuLink page =
    li [] [ button [ onClick (NavigationAction page.pageType) ] [ text page.title ] ]


renderPage : Page -> Html Msg
renderPage page =
    div []
        [ div [] [ text page.title ]
        , div [] [ text (toString page) ]
        , div [] [ page.content ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ div []
            [-- text (toString model)
            ]
        , div [] [ renderMainMenu model.currentUser allPages ]
        , div [] [ renderUserMenu model.currentUser ]
        , div [] [ renderPage model.currentPage ]
        ]
