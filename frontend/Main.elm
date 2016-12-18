module Main exposing (..)

import Array
import Html.App as App
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Html.Events exposing (onClick)
import Material
import Material.Scheme
import Material.Button as Button
import Material.Options exposing (css)
import Material.Layout as Layout
import UserProfile
import Home
import Routing exposing (..)


main : Program Never
main =
    App.program
        { init = ( init, Cmd.none )
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }



-- MODEL


type alias Model =
    { mdl : Material.Model
    , currentUser : Maybe User
    , currentPage : Page
    }


init : Model
init =
    { currentPage = allPages |> getPage HomePageTyp
    , currentUser = Nothing
    , mdl = Material.model
    }


type alias User =
    { email : String }


type PageType
    = HomePageTyp
    | AboutPageTyp
    | ProfilePageTyp
    | ErrorPageType


type Msg
    = NavigationAction PageType
    | Login User
    | Logout
    | SelectTab Int
    | Mdl (Material.Msg Msg)


type alias Page =
    { pageType : PageType
    , title : String
    , needsUser : Bool
    , content : Html Msg
    }


type alias PageRaw =
    { title : String
    , needsUser : Bool
    , content : Html Msg
    }


registerPage : PageRaw -> PageType -> Page
registerPage rawPage pageType =
    case pageType of
        _ ->
            { pageType = pageType
            , title = rawPage.title
            , needsUser = rawPage.needsUser
            , content = rawPage.content
            }


errorPage : PageRaw
errorPage =
    { title = "404"
    , needsUser = False
    , content = div [] []
    }


allPages : List Page
allPages =
    [ HomePageTyp |> registerPage Home.page
    , ProfilePageTyp |> registerPage UserProfile.page
    , ErrorPageType |> registerPage errorPage
    ]


getPage : PageType -> List Page -> Page
getPage pageType pages =
    case
        pages
            |> List.filter (\page -> (page.pageType == pageType))
            |> List.head
    of
        Nothing ->
            allPages
                |> getPage ErrorPageType

        Just page ->
            page


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigationAction pageType ->
            let
                currentPage =
                    model.currentUser
                        |> getPagesForUser
                        |> getPage pageType
            in
                ( { model | currentPage = currentPage }
                , Cmd.none
                )

        Login user ->
            let
                currentPage =
                    model.currentUser
                        |> getPagesForUser
                        |> getPage model.currentPage.pageType
            in
                ( { model | currentUser = Just user, currentPage = currentPage }
                , Cmd.none
                )

        Logout ->
            ( { model | currentUser = Nothing, currentPage = allPages |> getPage HomePageTyp }
            , Cmd.none
            )

        Mdl msg' ->
            Material.update msg' model

        SelectTab num ->
            let
                currentPage =
                    model.currentUser
                        |> getPagesForUser
                        |> getPageByTabIndex num
            in
                ( { model | currentPage = currentPage }
                , Cmd.none
                )


getPageByTabIndex : Int -> List Page -> Page
getPageByTabIndex num pages =
    case pages |> Array.fromList |> Array.get num of
        Nothing ->
            allPages |> getPage ErrorPageType

        Just page ->
            page


indicesOf : a -> List a -> List Int
indicesOf thing things =
    things
        |> List.indexedMap (,)
        |> List.filter (\( idx, item ) -> item == thing)
        |> List.map fst


firstIndexOf : a -> List a -> Int
firstIndexOf thing things =
    indicesOf thing things
        |> List.minimum
        |> Maybe.withDefault -1


getPagesForUser : Maybe User -> List Page
getPagesForUser user =
    case user of
        Nothing ->
            allPages |> List.filter (\page -> page.needsUser == False && page.pageType /= ErrorPageType)

        _ ->
            allPages |> List.filter (\page -> page.pageType /= ErrorPageType)



-- VIEW


type alias Mdl =
    Material.Model


renderTabLink : Page -> Html Msg
renderTabLink page =
    a [] [ text page.title ]


renderTabs : List Page -> List (Html Msg)
renderTabs pages =
    List.map renderTabLink (pages)


renderPage : Page -> Html Msg
renderPage page =
    div []
        [ div [] [ text page.title ]
        , div [] [ text (toString page) ]
        , div [] [ page.content ]
        ]


drawer : Maybe User -> List (Html Msg)
drawer user =
    [ Layout.title [] [ text "Example drawer" ]
    , Layout.navigation
        []
        [ case user of
            Nothing ->
                a [ onClick (Login dummyUser), class "mdl-navigation__link" ] [ text "Login" ]

            Just user ->
                div []
                    [ a [ onClick (Logout), class "mdl-navigation__link" ] [ text "Logout" ]
                    , a [ onClick (NavigationAction ProfilePageTyp), class "mdl-navigation__link" ] [ text "my Profile" ]
                    ]
        ]
    ]


view : Model -> Html Msg
view model =
    Layout.render Mdl
        model.mdl
        [ Layout.fixedHeader
        , model.currentUser |> getPagesForUser |> firstIndexOf model.currentPage |> Layout.selectedTab
        , Layout.onSelectTab SelectTab
        ]
        { header =
            [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "Page" ]
            ]
        , drawer = model.currentUser |> drawer
        , tabs =
            ( model.currentUser |> getPagesForUser |> renderTabs
            , []
            )
        , main = [ viewBody model ]
        }
        |> Material.Scheme.top


viewBody : Model -> Html Msg
viewBody model =
    div []
        [ div [] [ renderUserMenu model.currentUser ]
        , div [] [ renderPage model.currentPage ]
        ]
