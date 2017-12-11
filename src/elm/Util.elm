module Util exposing (..)

import Process
import Task
import Time


{-| helper to do a command after a certain amount of time
-}
wait : Time.Time -> msg -> Cmd msg
wait time msg =
    Process.sleep time |> Task.perform (\_ -> msg)


{-| helper to sequence another message from inside of an update
-}
send : msg -> Cmd msg
send msg =
    Task.succeed msg |> Task.perform identity
