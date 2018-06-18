module Data.Helpers exposing (..)


apiUrl : String -> String
apiUrl str =
    "https://api.nanobox.io/v2/" ++ str
