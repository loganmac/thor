module Util exposing (..)

{- Convenience for making tuples. Looks nicer in conjunction with classList. -}


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
