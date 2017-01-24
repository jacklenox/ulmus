port module Ulmus exposing (..)

import Dom.Scroll exposing (toTop)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Http
import Json.Decode as Decode exposing (Decoder, field, at, succeed)
import Markdown
import Navigation
import UrlParser as Url exposing((</>), (<?>), s, int, string, stringParam, top)


-- MODEL

type alias Model =
    { route : Route
    , history : List (Maybe Route)
    , posts : List Post
    , havePosts : Bool
    , apiUrl : String
    }


type alias Post =
    { id : Int
    , date : String
    , slug : String
    , link : String
    , content : String
    , title : String
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , history = []
    , posts = []
    , havePosts = False
    , apiUrl = ""
    }

init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    let
        currentRoute =
            parseLocation location
    in
        ( initialModel currentRoute, Cmd.none )


-- URL PARSING


type Route
    = Home
    | BlogPost Int Int Int String
    | NotFoundRoute


type alias PostRoute = { year : Int, month : Int, day : Int, slug : String }


rawPost : Url.Parser (Int -> Int -> Int -> String -> slug) slug
rawPost =
    int </> int </> int </> string


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map BlogPost rawPost
        ]


parseLocation : Navigation.Location -> Route
parseLocation location =
    case (Url.parsePath route location) of
        Just route ->
            route
        
        Nothing ->
            NotFoundRoute


-- UPDATE


type Msg =
    GetPosts (Result Http.Error (List Post))
    | ApiUrl (String)
    | NewUrl String
    | UrlChange Navigation.Location
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPosts (Ok latestPosts) ->
            ( { model | posts = latestPosts, havePosts = True }, Cmd.none )

        GetPosts (Err error) ->
            let
                _ = Debug.log "Oops!" error
            in
                (model, Cmd.none)

        ApiUrl newApiUrl ->
            ( { model | apiUrl = newApiUrl }, getPosts newApiUrl)

        NewUrl url ->
            ( model
            , Navigation.newUrl url
            )

        UrlChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | route = newRoute }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


-- DECODERS

postDecoder : Decoder Post
postDecoder = 
    Decode.map6 Post
        (field "id" Decode.int)
        (field "date" Decode.string)
        (field "slug" Decode.string)
        (field "link" Decode.string)
        (at ["content", "rendered"] Decode.string)
        (at ["title", "rendered"] Decode.string)


-- COMMANDS

getPosts : String -> Cmd Msg
getPosts apiUrl =
    (Decode.list postDecoder)
        |> Http.get (apiUrl ++ "posts")
        |> Http.send GetPosts


onPrevDefClick : msg -> Attribute msg
onPrevDefClick message =
    onWithOptions "click" { stopPropagation = True, preventDefault = True } (Decode.succeed message)


-- SUBSCRIPTIONS

port apiUrl : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
    apiUrl ApiUrl


-- VIEW

view : Model -> Html Msg
view model =
    div [ id "page", class "site" ]
        [ div [ class "content" ]
            [ header [ id "masthead", class "site-header" ]
                [ div [ class "site-branding" ]
                    [ h1 [ class "site-title" ] [
                        a [ href "/", onPrevDefClick (NewUrl "/") ]
                            [ text "WordPress ♥ Elm ♥ REST API" ]
                        ]
                    ]
                ]
            , page model
            ]
        ]

page : Model -> Html Msg
page model =
    case model.route of
        Home ->
            viewPostList model.posts

        BlogPost year month day slug ->
            viewSinglePost model slug

        NotFoundRoute ->
            viewNotFound


viewPostList : List Post -> Html Msg
viewPostList posts =
    let
        listOfPosts =
            List.map viewPost posts
    in
        div [] listOfPosts


viewSinglePost : Model -> String -> Html Msg
viewSinglePost model slug =
    let
        maybePost =
            model.posts
                |> List.filter (\post -> post.slug == slug)
                |> List.head
    in
        case maybePost of
            Just post ->
                div [] [ viewPost post ]

            Nothing ->
                viewNotFound


viewPost : Post -> Html Msg
viewPost post =
    section [ class "post" ]
        [ h2 [] [
            a [ href post.link, onPrevDefClick (NewUrl post.link) ]
                [ text post.title ]
        ]
        , article [ class "content"]
            [ Markdown.toHtml [] post.content ]
        ]


viewNotFound : Html Msg
viewNotFound =
    div []
        [ text "Not found" ]


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
