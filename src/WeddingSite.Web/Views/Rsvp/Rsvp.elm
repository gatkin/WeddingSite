import Browser
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (class, disabled, id, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, int, list, string)
import Set exposing (Set)


main =
  Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


-- MODEL

type alias GuestId = Int

type GuestStatus
  = Unregistered
  | Attending
  | NotAttending

type alias Guest =
  { id: GuestId
  , name: String
  , status: GuestStatus
  , isSelected: Bool
  , isVisible: Bool
  }

type alias PlusOnePair = (String, String)

type alias GuestResponseModel =
  { id: GuestId
  , name: String
  }

type alias PlusOneResponseModel =
  { partnerAName: String
  , partnerBName: String
  }

type alias GetGuestListReponse =
  { guests: List GuestResponseModel
  , plusOnes: List PlusOneResponseModel
  }

type alias Model =
  { guests: List Guest
  , plusOnes: List PlusOnePair
  , searchString: String
  }


init : () -> (Model, Cmd Msg)
init () =
  ( { guests = []
    , plusOnes = []
    , searchString = ""
    }
  , getGuestList
  ) 


-- UPDATE

type Msg = GuestListLoaded (Result Http.Error GetGuestListReponse)
  | SelectGuest GuestId
  | NewSearch String
  | AttendingSubmitted
  | NotAttendingSubmitted


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GuestListLoaded result ->
      case result of
        Ok response ->
          (onGuestListLoaded response model, Cmd.none)
        Err _ ->
          (model, Cmd.none)
    SelectGuest guestId ->
      (onGuestSelected guestId model, Cmd.none)
    NewSearch searchString ->
      (onNewSearch searchString model, Cmd.none)
    AttendingSubmitted ->
      (model, Cmd.none)
    NotAttendingSubmitted ->
      (model, Cmd.none)


onGuestListLoaded : GetGuestListReponse -> Model -> Model
onGuestListLoaded response model =
  let
      guests = response.guests |> List.map guestResponseModelToGuest
      plusOnes = response.plusOnes |> List.map plusOneResponseModelToPlusOnePair
  in
    { model | guests = guests, plusOnes = plusOnes }
  

guestResponseModelToGuest : GuestResponseModel -> Guest
guestResponseModelToGuest model =
  { id = model.id, name = model.name, status = Unregistered, isSelected = False, isVisible = True }


plusOneResponseModelToPlusOnePair : PlusOneResponseModel -> PlusOnePair
plusOneResponseModelToPlusOnePair model =
  (model.partnerAName, model.partnerBName)


onGuestSelected : GuestId -> Model -> Model
onGuestSelected guestId model =
  let
      newGuestList = model.guests |> List.map (selectGuestIfIdMatches guestId)
  in
    { model | guests = newGuestList }


selectGuestIfIdMatches : GuestId -> Guest -> Guest
selectGuestIfIdMatches guestId guest =
  if guestId == guest.id then
    { guest | isSelected = not guest.isSelected }
  else
    guest


onNewSearch : String -> Model -> Model
onNewSearch searchString model =
  let
      cleanSearchString = searchString |> String.trim |> String.toLower
      matchingPlusOneNames = getMatchingPlusOneNames cleanSearchString model.plusOnes
      newGuestList =  filterGuestsOnSearchString cleanSearchString matchingPlusOneNames model.guests
  in
    { model | searchString = cleanSearchString, guests = newGuestList }


getMatchingPlusOneNames : String -> List PlusOnePair -> Set String
getMatchingPlusOneNames searchString plusOnes =
  plusOnes
    |> List.filterMap (getPlusOneNameIfMatchesSearchString searchString)
    |> Set.fromList


getPlusOneNameIfMatchesSearchString : String -> PlusOnePair -> Maybe String
getPlusOneNameIfMatchesSearchString searchString (partnerA, partnerB) =
  if doesGuestNameMatchSearchString searchString partnerA then
    Just partnerB
  else if doesGuestNameMatchSearchString searchString partnerB then
    Just partnerA
  else
    Nothing


doesGuestNameMatchSearchString : String -> String -> Bool
doesGuestNameMatchSearchString searchString guestName =
  guestName |> String.toLower |> String.contains searchString


filterGuestsOnSearchString : String -> Set String -> List Guest -> List Guest
filterGuestsOnSearchString searchString matchingPlusOneNames guestList =
    guestList
      |> List.map (\guest -> { guest | isVisible = doesGuestMatchSearchString searchString matchingPlusOneNames guest })


doesGuestMatchSearchString : String -> Set String -> Guest -> Bool
doesGuestMatchSearchString searchString matchingPlusOneNames guest =
  String.isEmpty searchString
  || doesGuestNameMatchSearchString searchString guest.name
  || Set.member guest.name matchingPlusOneNames


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
  [ titleView
  , searchBarView
  , guestListView model.guests
  , submitButtonView model.guests
  ]


titleView : Html Msg
titleView =
  div [ class "row", id "title-row" ]
  [ div [ class "col-12"]
    [ h1 [] [ text "RSVP" ]
    ]
  ]


searchBarView : Html Msg
searchBarView =
  div [ class "row", id "search-bar-row" ]
  [ div [ class "col-3" ] []
  , div [ class "col-6" ]
    [ input [ class "form-control", placeholder "Search", onInput NewSearch ] []
    ]
  , div [ class "col-3" ] []
  ]


guestView : Guest -> Html Msg
guestView guest =
  let
      buttonOutline = if guest.isSelected then "btn-primary" else "btn-outline-primary"
      buttonClass = "btn " ++ buttonOutline
  in
    div [ class "guest-name" ]
    [ button [ class buttonClass, type_ "button", onClick (SelectGuest guest.id) ]
      [ text guest.name ]
    ]


guestListView : List Guest -> Html Msg
guestListView guests =
  let
    guestViews = guests
      |> List.filter (\guest -> guest.isVisible)
      |> List.map guestView
  in
    div [ class "row" ]
    [ div [ class "col-2" ] []
    , div [ class "col-8", id "guest-list-container" ]  guestViews
    , div [ class "col-2" ]  []
    ]


submitButtonView : List Guest -> Html Msg
submitButtonView guestList =
  let
      disableButtons = guestList
        |> List.any (\guest -> guest.isVisible && guest.isSelected)
        |> not
  in
    div [ class "submit-button-row row" ]
    [ div [ class "col-4" ] []
    , div [ class "col-4", id "submit-button-container" ]
      [ button [ class "submit-button btn btn-success", type_ "button", disabled disableButtons, onClick AttendingSubmitted ] [ text "Attending" ]
      , button [ class "submit-button btn btn-danger", type_ "button", disabled disableButtons, onClick NotAttendingSubmitted ] [ text "Not Attending" ]
      ]
    , div [ class "col-4" ] []
    ]


-- HTTP

getGuestList : Cmd Msg
getGuestList =
  Http.get
    { url = "/Rsvp/Guests"
    , expect = Http.expectJson GuestListLoaded getGuestListResponseDecoder
    }


getGuestListResponseDecoder : Decoder GetGuestListReponse
getGuestListResponseDecoder =
  Json.Decode.map2 GetGuestListReponse
    (field "guests" (list guestResponseModelDecoder))
    (field "plusOnes" (list plusOneResponseModelDecoder))


guestResponseModelDecoder : Decoder GuestResponseModel
guestResponseModelDecoder =
  Json.Decode.map2 GuestResponseModel
    (field "id" int)
    (field "name" string)
  

plusOneResponseModelDecoder : Decoder PlusOneResponseModel
plusOneResponseModelDecoder =
  Json.Decode.map2 PlusOneResponseModel
    (field "partnerAName" string)
    (field "partnerBName" string)