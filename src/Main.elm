module Main exposing (..)

import Api.Random as Api
import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Http
import Json.Encode as E


type alias Model =
    { randomNumbers : List Int
    , errorMessage : String
    }


type Msg
    = FetchRandomNumbers
    | RandomNumbersFetched (Result Http.Error Api.ApiResponse)


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
            Api.rpcGenerateIntegers 5 1 6
                |> Api.rpcCallEncoder
                |> E.encode 0
    in
    Http.post
        { url = url
        , body = Http.stringBody "application/json" payload
        , expect = Http.expectJson RandomNumbersFetched Api.apiResponseDecoder
        }
