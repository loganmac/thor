module Data.AppDash exposing (..)

import Data.Helpers exposing (apiUrl)
import Http
import Json.Decode as Decode exposing (Decoder, nullable)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)


-- MODEL


type alias AppDash =
    { id : String
    , name : String
    , hosts : List Host
    , clusters : List Cluster
    }


type alias Host =
    { id : String
    , name : String
    , components : List Component
    }


type alias Component =
    { id : String
    , parentId : String
    , name : String
    }


type alias Cluster =
    { id : String
    , name : String
    }



-- we're just faking it for right now :) eventually we'll get the data
-- from the API and then setup decoders and an initial state


initialModel : AppDash
initialModel =
    { id = "odin-staging-1"
    , name = "odin-staging"
    , hosts =
        [ { id = "host-do-1"
          , name = "do.1"
          , components =
                [ { id = "component-data-db"
                  , parentId = "host-do-1"
                  , name = "data.db"
                  }
                , { id = "component-data-queue"
                  , parentId = "host-do-1"
                  , name = "data.queue"
                  }
                , { id = "component-data-uploads"
                  , parentId = "host-do-1"
                  , name = "data.uploads"
                  }
                ]
          }
        ]
    , clusters =
        [ { id = "cluster-web-dashboard"
          , name = "web.dashboard"
          }
        , { id = "cluster-worker-sequences"
          , name = "worker.sequences"
          }
        ]
    }
