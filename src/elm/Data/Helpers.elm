module Data.Helpers exposing (..)


apiUrl : String -> String
apiUrl str =
    "http://localhost:3000/" ++ str
