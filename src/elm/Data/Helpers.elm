module Data.Helpers exposing (..)


apiUrl : String -> String
apiUrl str =
    "http://localhost:4000/" ++ str
