module Components exposing (languageToColor, viewRepo)

import Html exposing (Html, a, div, span, text)
import Html.Attributes exposing (href, style)
import Message exposing (Msg)
import Repository exposing (Repo)


viewRepo : Repo -> Html Msg
viewRepo repo =
    div
        [ style "border-color" "#e02c6d"
        , style "border-style" "solid"
        , style "margin" "5px"
        , style "padding" "10px"
        , style "background-color" "#303030"
        , style "border-radius" "5px"
        ]
        [ div [] [ a [ href repo.url, style "text-decoration" "none" ] [ text repo.name ] ]
        , div [] [ text repo.description ]
        , div [] [ text <| ("⭐" ++ String.fromInt repo.stars) ]
        , let
            lang =
                Maybe.withDefault "Other" <| repo.language
          in
          div [] [ span [ style "color" <| languageToColor lang ] [ text "● " ], text lang ]
        ]


languageToColor : String -> String
languageToColor lang =
    case lang of
        "Lua" ->
            "#000080"

        "Rust" ->
            "#dea584"

        "C++" ->
            "#f34b7d"

        "Raku" ->
            "#0000fb"

        "Prolog" ->
            "#74283c"

        "Elm" ->
            "#60b5cc"

        _ ->
            "#ffffff"
