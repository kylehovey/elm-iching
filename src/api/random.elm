module Api.Random exposing (..)

import Json.Decode exposing (Decoder, field, list, int, string)

type alias ApiResponse =
    { jsonrpc: String
    , result : RandomData
    , id : Int
    }

apiResponseDecoder : Decoder ApiResponse
apiResponseDecoder =
    Json.Decode.map3 ApiResponse
        (field "jsonrpc" string)
        (field "result" randomDataDecoder)
        (field "id" int)

type alias RandomData =
    { random : RandomInts
    , bitsUsed : Int
    , bitsLeft : Int
    }

randomDataDecoder : Decoder RandomData
randomDataDecoder =
    Json.Decode.map3 RandomData
        (field "random" randomIntsDecoder)
        (field "bitsUsed" int)
        (field "bitsLeft" int)

type alias RandomInts =
    { data : List Int
    , completionTime : String
    }

randomIntsDecoder : Decoder RandomInts
randomIntsDecoder =
    Json.Decode.map2 RandomInts
      (field "data" (list int))
      (field "completionTime" string)
