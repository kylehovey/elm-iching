module Main exposing (..)

import Api.ApiKey exposing (apiKey)
import Api.Random exposing (ApiResponse, apiResponseDecoder)
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http


type alias Model =
    { randomNumbers : List Int
    , errorMessage : String
    }


type Msg
    = FetchRandomNumbers
    | RandomNumbersFetched (Result Http.Error ApiResponse)


init : Model
init =
    { randomNumbers = []
    , errorMessage = ""
    }


main : Program {} Model Msg
main =
    Browser.element
        { init = \_ -> ( init, Cmd.none )
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchRandomNumbers ->
            ( model, fetchRandomNumbers )

        RandomNumbersFetched result ->
            case result of
                Ok apiResponse ->
                    ( { model | randomNumbers = apiResponse.result.random.data, errorMessage = "" }, Cmd.none )

                Err _ ->
                    ( { model | randomNumbers = [], errorMessage = "Failed to fetch random numbers." }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick FetchRandomNumbers ] [ text "Get Random Numbers" ]
        , div []
            [ case model.randomNumbers of
                [] ->
                    text model.errorMessage

                numbers ->
                    div [] [ text (String.join ", " (List.map String.fromInt numbers)) ]
            ]
        ]


fetchRandomNumbers : Cmd Msg
fetchRandomNumbers =
    let
        url =
            "https://api.random.org/json-rpc/2/invoke"

        payload =
            String.join ""
                [ """
            {
                "jsonrpc": "2.0",
                "method": "generateIntegers",
                "params": {
            """
                , "\"apiKey\": \"" ++ apiKey ++ "\",\n"
                , """
                    "n": 6,
                    "min": 1,
                    "max": 6,
                    "replacement": true
                },
                "id": 42
            }
            """
                ]
    in
    Http.post
        { url = url
        , body = Http.stringBody "application/json" payload
        , expect = Http.expectJson RandomNumbersFetched apiResponseDecoder
        }
