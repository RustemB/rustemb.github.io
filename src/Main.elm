module Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (align, href, src, style)
import Http
import Json.Decode as J


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


type alias Repo =
    { name : String
    , description : String
    , stars : Int
    , url : String
    , isFork : Bool
    , pushedAt : String
    }


type Msg
    = Update
    | GotRepos (Result Http.Error (List Repo))


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
        J.map6 Repo
            (J.field "name" J.string)
            (J.field "description" J.string)
            (J.field "stargazers_count" J.int)
            (J.field "html_url" J.string)
            (J.field "fork" J.bool)
            (J.field "pushed_at" J.string)


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
        [ div []
            [ viewProfileImage model
            , viewRepos model
            ]
        ]
    }


viewProfileImage : Model -> Html Msg
viewProfileImage _ =
    div
        [ align "center"
        , style "margin" "5px"
        ]
        [ img
            [ style "border-radius" "50%"
            , style "border-style" "solid"
            , style "border-color" "black"
            , src "https://avatars.githubusercontent.com/u/25725953?v=4"
            ]
            []
        ]


viewRepos : Model -> Html Msg
viewRepos model =
    case model of
        Failure ->
            div [ style "text-color" "red" ] [ text "ERROR!!!" ]

        Loading ->
            div [] [ text "Loading..." ]

        Success repos ->
            div [ style "align-items" "center" ] <|
                List.map viewRepo <|
                    List.reverse <|
                        List.sortBy .pushedAt <|
                            List.filter (not << .isFork) repos


viewRepo : Repo -> Html Msg
viewRepo repo =
    div
        [ style "border-color" "black"
        , style "border-style" "solid"
        , style "margin" "5px"
        , style "padding" "10px"
        , style "margin-left" "30%"
        , style "margin-right" "30%"
        ]
        [ div [] [ a [ href repo.url ] [ text repo.name ] ]
        , div [] [ text repo.description ]
        , div [] [ text <| ("⭐" ++ String.fromInt repo.stars) ]
        ]
