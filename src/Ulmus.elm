port module Ulmus exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Parser
import Html.Parser.Util
import Http
import Json.Decode as Decode exposing (Decoder, field, at, succeed)
import Url exposing (Url)
import Url.Parser as UrlParser exposing((</>), (<?>), s, int, string, top)


-- MODEL

type alias Model =
    { key : Nav.Key
    , path : Route
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


initialModel : Nav.Key -> Route -> Model
initialModel key path =
    { key = key
    , path = path
    , history = []
    , posts = []
    , havePosts = False
    , apiUrl = ""
    }

init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    let
        currentRoute =
            parseLocation url
    in
        ( initialModel key currentRoute, Cmd.none )


-- URL PARSING


type Route
    = Home
    | BlogPost Int Int Int String
    | NotFoundRoute


type alias PostRoute = { year : Int, month : Int, day : Int, slug : String }


rawPost : UrlParser.Parser (Int -> Int -> Int -> String -> slug) slug
rawPost =
    int </> int </> int </> string


route : UrlParser.Parser (Route -> a) a
route =
    UrlParser.oneOf
        [ UrlParser.map Home top
        , UrlParser.map BlogPost rawPost
        ]


parseLocation : Url -> Route
parseLocation location =
    case (UrlParser.parse route location) of
        Just path ->
            path
        
        Nothing ->
            NotFoundRoute


-- UPDATE


type Msg =
    GetPosts (Result Http.Error (List Post))
    | ApiUrl (String)
    | ClickLink UrlRequest
    | UrlChange Url
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetPosts (Ok latestPosts) ->
            ( { model | posts = latestPosts, havePosts = True }, Cmd.none )

        GetPosts (Err error) ->
            (model, Cmd.none)

        ApiUrl newApiUrl ->
            ( { model | apiUrl = newApiUrl }, getPosts newApiUrl)

        ClickLink urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Nav.pushUrl model.key <| Url.toString url )
                External url ->
                    ( model, Nav.load url )

        UrlChange location ->
            let
                newRoute =
                    parseLocation location
            in
                ( { model | path = newRoute }, Cmd.none )

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
getPosts getApiUrl =
    Http.get
        { url = getApiUrl ++ "posts"
        , expect = Http.expectJson GetPosts (Decode.list postDecoder)
        }


-- SUBSCRIPTIONS

port apiUrl : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
    apiUrl ApiUrl


-- VIEW

view : Model -> Document Msg
view model =
    { title = "WordPress ♥ Elm ♥ REST API"
    , body =
        [ div [ id "page", class "site" ]
            [ div [ class "content" ]
                [ header [ id "masthead", class "site-header" ]
                    [ div [ class "site-branding" ]
                        [ h1 [ class "site-title" ] [
                            a [ href "/" ]
                                [ text "WordPress ♥ Elm ♥ REST API" ]
                            ]
                        ]
                    ]
                , page model
                ]
            ]
        ]
    }

page : Model -> Html Msg
page model =
    case model.path of
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
    let
        nodes =
            case Html.Parser.run post.content of
                Ok parsedNodes ->
                    Html.Parser.Util.toVirtualDom parsedNodes
                _ ->
                    []
    in
    section [ class "post" ]
        [ h2 [] [
            a [ href post.link ]
                [ text post.title ]
        ]
        , article [ class "content"]
            nodes
        ]


viewNotFound : Html Msg
viewNotFound =
    div []
        [ text "Not found" ]


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickLink
        , onUrlChange = UrlChange
        }
