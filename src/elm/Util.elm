module Util exposing (..)

import Process
import Task
import Time


{-| helper to do a command after a certain amount of seconds
-}
wait : Float -> msg -> Cmd msg
wait seconds msg =
    Process.sleep (Time.second * seconds) |> Task.perform (\_ -> msg)


{-| helper to sequence another message from inside of an update
-}
send : msg -> Cmd msg
send msg =
    Task.succeed msg |> Task.perform identity


{-| infix operator for tuples, makes them appear a lot nicer.
-}
(=>) : a -> b -> ( a, b )
(=>) =
    (,)


{-| infixl 0 means the (=>) operator has the same precedence as (<|) and (|>),
meaning you can use it at the end of a pipeline and have the precedence work out.
-}
infixl 0 =>
