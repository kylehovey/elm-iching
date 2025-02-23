module Api.Random exposing (..)

import Api.ApiKey exposing (apiKey)
import Json.Decode as D
import Json.Encode as E


type alias ApiResponse =
    { jsonrpc : String
    , result : RandomData
    , id : String
    }


apiResponseDecoder : D.Decoder ApiResponse
apiResponseDecoder =
    D.map3 ApiResponse
        (D.field "jsonrpc" D.string)
        (D.field "result" randomDataDecoder)
        (D.field "id" D.string)


type alias RandomData =
    { random : RandomInts
    , bitsUsed : Int
    , bitsLeft : Int
    }


randomDataDecoder : D.Decoder RandomData
randomDataDecoder =
    D.map3 RandomData
        (D.field "random" randomIntsDecoder)
        (D.field "bitsUsed" D.int)
        (D.field "bitsLeft" D.int)


type alias RandomInts =
    { data : List Int
    , completionTime : String
    }


randomIntsDecoder : D.Decoder RandomInts
randomIntsDecoder =
    D.map2 RandomInts
        (D.field "data" (D.list D.int))
        (D.field "completionTime" D.string)


type alias GenerateIntegersParams =
    { n : Int
    , min : Int
    , max : Int
    , replacement : Bool
    , apiKey : String
    }


type Params
    = GenerateIntegers GenerateIntegersParams


paramsEncoder : Params -> E.Value
paramsEncoder (GenerateIntegers { n, min, max, replacement, apiKey }) =
    E.object
        [ ( "apiKey", E.string apiKey )
        , ( "n", E.int n )
        , ( "min", E.int min )
        , ( "max", E.int max )
        , ( "replacement", E.bool replacement )
        ]


type alias RpcCall =
    { id : String
    , method : String
    , params : Params
    }


rpcCallEncoder : RpcCall -> E.Value
rpcCallEncoder { id, method, params } =
    E.object
        [ ( "jsonrpc", E.string "2.0" )
        , ( "id", E.string id )
        , ( "method", E.string method )
        , ( "params", paramsEncoder params )
        ]



-- API Section


generateIntegersParams : Int -> Int -> Int -> Params
generateIntegersParams n min max =
    GenerateIntegers
        { n = n
        , min = min
        , max = max
        , apiKey = apiKey
        , replacement = False
        }


rpcGenerateIntegers : Int -> Int -> Int -> RpcCall
rpcGenerateIntegers n min max =
    { id = "42"
    , method = "generateIntegers"
    , params = generateIntegersParams n min max
    }
