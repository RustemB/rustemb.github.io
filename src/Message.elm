module Message exposing (Msg(..))

import Http
import Repository exposing (Repo)


type Msg
    = Update
    | GotRepos (Result Http.Error (List Repo))
