module Repository exposing (Repo)


type alias Repo =
    { name : String
    , description : String
    , stars : Int
    , url : String
    , isFork : Bool
    , pushedAt : String
    , language : Maybe String
    , isArchived : Bool
    }
