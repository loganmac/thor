module Data.Helpers exposing (..)


apiUrl : String -> String
apiUrl str =
    "https://api.jedgalbraith.com/v2/" ++ str
