import Browser
import Html exposing (Html, button, div, h1, h3, input, span, text)
import Html.Attributes exposing (class, disabled, id, placeholder, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, list, string)
import Json.Encode as Encode
import Set exposing (Set)


main =
  Browser.element { init = init, update = update, subscriptions = subscriptions, view = view }


-- MODEL

type alias GuestId = String

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

type RsvpSubmissionStatus = NotSubmitted
  | WaitingForResponse
  | Submitted

type alias Model =
  { guests: List Guest
  , plusOnes: List PlusOnePair
  , searchString: String
  , rsvpSubmissionStatus: RsvpSubmissionStatus
  }


init : () -> (Model, Cmd Msg)
init () =
  ( { guests = []
    , plusOnes = []
    , searchString = ""
    , rsvpSubmissionStatus = NotSubmitted
    }
  , getGuestList
  ) 


-- UPDATE

type Msg = GuestListLoaded (Result Http.Error GetGuestListReponse)
  | SelectGuest GuestId
  | NewSearch String
  | AttendingSubmitted
  | NotAttendingSubmitted
  | RsvpSubmissionResponse (Result Http.Error ())
  | AddAnotherRsvp


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
      onRsvpSubmitted True model
    NotAttendingSubmitted ->
      onRsvpSubmitted False model
    RsvpSubmissionResponse result ->
      case result of
        Ok _ ->
          (onRsvpSubmissionResponse model, Cmd.none)
        Err _ ->
          (model, Cmd.none)
    AddAnotherRsvp ->
      (onAddAnotherRsvp model, Cmd.none)


onGuestListLoaded : GetGuestListReponse -> Model -> Model
onGuestListLoaded response model =
  let
      guests = response.guests
        |> List.map guestResponseModelToGuest
        |> List.sortWith orderByName
      plusOnes = response.plusOnes |> List.map plusOneResponseModelToPlusOnePair
  in
    { model | guests = guests, plusOnes = plusOnes }


orderByName : Guest -> Guest -> Order
orderByName a b =
  let
      (aFirst, aLast) = getFirstAndLastName a
      (bFirst, bLast) = getFirstAndLastName b
  in
      if aLast == bLast then
        compare aFirst bFirst
      else
        compare aLast bLast


getFirstAndLastName : Guest -> (String, String)
getFirstAndLastName guest =
  let
      names = String.split " " guest.name
      firstName = names |> List.head |> Maybe.withDefault guest.name
      lastName = names |> List.drop 1 |> List.head |> Maybe.withDefault guest.name
  in
    (firstName, lastName)


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


onRsvpSubmitted : Bool -> Model -> (Model, Cmd Msg)
onRsvpSubmitted isAttending model =
    ({ model | rsvpSubmissionStatus = WaitingForResponse }, postRsvpRequest isAttending model.guests)


onRsvpSubmissionResponse : Model -> Model
onRsvpSubmissionResponse model =
  { model | rsvpSubmissionStatus = Submitted }


onAddAnotherRsvp : Model -> Model
onAddAnotherRsvp model =
  let
    newGuests = model.guests |> List.map (\guest -> {guest | isVisible = True, isSelected = False})
  in
    { model | searchString = "", rsvpSubmissionStatus = NotSubmitted, guests = newGuests }


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  if model.rsvpSubmissionStatus == Submitted then
    completedFormView
  else
    incompleteFormView model
    

incompleteFormView : Model -> Html Msg
incompleteFormView model =
  let
    inputDisabled = model.rsvpSubmissionStatus == WaitingForResponse
  in
    div [ class "container-fluid" ]
    [ titleView
    , searchBarView inputDisabled
    , guestListView model.guests inputDisabled
    , submitButtonView model.guests inputDisabled
    ]


completedFormView : Html Msg
completedFormView =
  div [ class "container-fluid"]
  [ titleView
  , thankYouView
  , addAnotherRsvpView
  ]


titleView : Html Msg
titleView =
  div [ class "row", id "title-row" ]
  [ div [ class "col-12"]
    [ h1 [] [ text "RSVP" ]
    ]
  ]


searchBarView : Bool -> Html Msg
searchBarView inputDisabled =
  div [ class "row", id "search-bar-row" ]
  [ div [ class "col-sm-3" ] []
  , div [ class "col-sm-6" ]
    [ input [ class "form-control", placeholder "Search", onInput NewSearch, disabled inputDisabled ] []
    ]
  , div [ class "col-sm-3" ] []
  ]


guestListView : List Guest -> Bool -> Html Msg
guestListView guests inputDisabled =
  let
    guestViews = guests
      |> List.filter (\guest -> guest.isVisible)
      |> List.map (guestView inputDisabled)
  in
    div [ class "row" ]
    [ div [ class "col-sm-2" ] []
    , div [ class "col-sm-8", id "guest-list-container" ]  guestViews
    , div [ class "col-sm-2" ]  []
    ]


guestView : Bool -> Guest -> Html Msg
guestView inputDisabled guest =
  let
      buttonOutline = if guest.isSelected then "selected-guest" else "unselected-guest"
      buttonClass = "btn " ++ buttonOutline
  in
    div [ class "guest-name" ]
    [ button [ class buttonClass, type_ "button", onClick (SelectGuest guest.id), disabled inputDisabled ]
      [ text guest.name ]
    ]


submitButtonView : List Guest -> Bool -> Html Msg
submitButtonView guestList inputDisabled =
  let
      anySelectedGuests = guestList |> List.any (\guest -> guest.isVisible && guest.isSelected)
      buttonsDisabled = inputDisabled || (not anySelectedGuests)
  in
    div [ class "submit-button-row row" ]
    [ div [ class "col-sm-4" ] []
    , div [ class "col-sm-4", id "submit-button-container" ]
      [ button [ id "attending-button", class "submit-button btn", type_ "button", disabled buttonsDisabled, onClick AttendingSubmitted ]
        [ text "Attending" ]
      , button [  id "not-attending-button", class "submit-button btn", type_ "button", disabled buttonsDisabled, onClick NotAttendingSubmitted ]
        [ span [ class "spinner-border spinner-border-sm" ] [],  text "Not Attending" ]
      ]
    , div [ class "col-4" ] []
    ]


thankYouView : Html Msg
thankYouView =
  div [ class "row" ]
  [ div [ class "col-sm-4" ] []
  , div [ class "col-sm-4" ]
    [ h3 [] [ text "Thank you for your response!" ]
    ]
  , div [ class "col-sm-4" ] []
  ]


addAnotherRsvpView : Html Msg
addAnotherRsvpView =
  div [ class "row add-another-rsvp-row" ]
  [ div [ class "col-12" ]
    [ button [ id "add-rsvp-btn", class "btn", type_ "button", onClick AddAnotherRsvp ] [ text "Add Another RSVP" ]
    ]
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
    (field "id" string)
    (field "name" string)
  

plusOneResponseModelDecoder : Decoder PlusOneResponseModel
plusOneResponseModelDecoder =
  Json.Decode.map2 PlusOneResponseModel
    (field "partnerAName" string)
    (field "partnerBName" string)


postRsvpRequest : Bool -> List Guest -> Cmd Msg
postRsvpRequest isAttending guests =
  let
    selectedGuestIds = getSelectedGuestIds guests
    jsonRequest = Encode.object
      [ ( "GuestIds", Encode.list Encode.string selectedGuestIds )
      , ( "IsAttending", Encode.bool isAttending )
      ]
  in
    Http.post
      { url = "/Rsvp/Attendance"
      , body = Http.jsonBody jsonRequest
      , expect = Http.expectWhatever RsvpSubmissionResponse
      }


getSelectedGuestIds : List Guest -> List GuestId
getSelectedGuestIds guests =
  guests
    |> List.filter (\guest -> guest.isSelected && guest.isVisible)
    |> List.map (\guest -> guest.id)
