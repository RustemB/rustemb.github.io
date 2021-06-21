module Main exposing (main)

import Browser exposing (Document)
import Html exposing (Html, a, div, img, text)
import Html.Attributes exposing (align, href, src, style)
import Http
import Json.Decode exposing (Decoder, Value, bool, decodeValue, field, int, list, string, value)


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
    | Success Repos


type alias Repo =
    { name : String
    , description : String
    , stars : Int
    , url : String
    , isFork : Bool
    , pushedAt : String
    }


type alias Repos =
    List Value


type Msg
    = Update
    | GotRepos (Result Http.Error Repos)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getReposList )


getReposList : Cmd Msg
getReposList =
    Http.get
        { url = "https://api.github.com/users/RustemB/repos"
        , expect = Http.expectJson GotRepos listDecode
        }


listDecode : Decoder (List Value)
listDecode =
    list value


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
                            List.filter (not << .isFork) <|
                                List.map decodeRepo repos


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


decodeRepo : Value -> Repo
decodeRepo repo =
    { name = Result.withDefault "" <| decodeValue (field "name" string) repo
    , description = Result.withDefault "" <| decodeValue (field "description" string) repo
    , stars = Result.withDefault 0 <| decodeValue (field "stargazers_count" int) repo
    , url = Result.withDefault "" <| decodeValue (field "html_url" string) repo
    , isFork = Result.withDefault False <| decodeValue (field "fork" bool) repo
    , pushedAt = Result.withDefault "" <| decodeValue (field "pushed_at" string) repo
    }