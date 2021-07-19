module Main exposing (main)

import Browser exposing (Document)
import Components as C
import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Http
import Json.Decode as J
import Message exposing (Msg(..))
import Repository exposing (Repo)


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type Model
    = Failure
    | Loading
    | Success (List Repo)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getReposList )


getReposList : Cmd Msg
getReposList =
    Http.get
        { url = "https://api.github.com/users/RustemB/repos"
        , expect = Http.expectJson GotRepos listDecode
        }


listDecode : J.Decoder (List Repo)
listDecode =
    J.list <|
        J.map8 Repo
            (J.field "name" J.string)
            (J.field "description" J.string)
            (J.field "stargazers_count" J.int)
            (J.field "html_url" J.string)
            (J.field "fork" J.bool)
            (J.field "pushed_at" J.string)
            (J.field "language" (J.maybe J.string))
            (J.field "archived" J.bool)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        Update ->
            ( Loading, getReposList )

        GotRepos result ->
            case result of
                Ok repos ->
                    ( Success repos, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Document Msg
view model =
    { title = "RustemB's portfolio"
    , body =
        [ stylesheet
        , div
            [ style "font-family" "FantasqueSansMonoRegular"
            , style "font-weight" "normal"
            , style "font-style" "normal"
            , style "background-color" "#1c1b19"
            , style "color" "#fce8c3"
            , style "position" "absolute"
            , style "top" "0"
            , style "left" "0"
            , style "width" "100%"
            ]
            [ C.viewProfileImage
            , viewRepos model
            ]
        ]
    }


viewRepos : Model -> Html Msg
viewRepos model =
    case model of
        Failure ->
            div [ style "text-color" "red" ] [ text "ERROR!!!" ]

        Loading ->
            div [] [ text "Loading..." ]

        Success repos ->
            div [ style "align-items" "center" ] <|
                List.map C.viewRepo <|
                    List.reverse <|
                        List.sortBy .pushedAt <|
                            List.filter (not << .isArchived) <|
                                List.filter (not << .isFork) repos


stylesheet : Html Msg
stylesheet =
    Html.node "style"
        []
        [ text """@import url(https://fontlibrary.org//face/fantasque-sans-mono);
a:link { color: #0aaeb3; }
a:visited { color: #2c78bf; }
a:hover { color: #68a8e4; }
"""
        ]
