import Browser
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (class, id, placeholder, type_)
import Html.Events exposing (onClick, onInput)


main =
  Browser.sandbox { init = init, update = update, view = view }


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

initialPlusOnes : List PlusOnePair
initialPlusOnes =
  [ ("John Doe", "Jane Doe")
  , ("Philip J Fry", "Turanga Leela")
  , ("Amy Wang", "Kif Kroker")
  ]

createGuest : String -> Int -> Guest
createGuest name guestId =
  { id = guestId, name = name, status = Unregistered, isSelected = False, isVisible = True }

initialGuests : List Guest
initialGuests =
  [ createGuest "John Doe" 1
  , createGuest "Jane Doe" 2
  , createGuest "Philip J Fry" 3
  , createGuest "Turanga Leela" 4
  , createGuest "Zapp Brannigan" 5
  , createGuest "Kif Kroker" 6
  , createGuest "Hermes Conrad" 7
  , createGuest "Bender Bending Rodrigez" 8
  , createGuest "Amy Wang" 9
  , createGuest "Zoidberg" 10
  ]


type alias Model =
  { guests: List Guest
  , plusOnes: List PlusOnePair
  , searchString: String
  }


init : Model
init =
  { guests = initialGuests
  , plusOnes = initialPlusOnes
  , searchString = ""
  }


-- UPDATE

type Msg = SelectGuest GuestId
  | NewSearch String


update : Msg -> Model -> Model
update msg model =
  case msg of
    SelectGuest guestId ->
      onGuestSelected guestId model
    NewSearch searchString ->
      onNewSearch searchString model


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
      newGuestList = model.guests |> filterGuestsOnSearchString cleanSearchString model.plusOnes
  in
    { model | searchString = cleanSearchString, guests = newGuestList }


filterGuestsOnSearchString : String -> List PlusOnePair -> List Guest -> List Guest
filterGuestsOnSearchString searchString plusOnes guestList =
    guestList
      |> List.map (setVisibleIfMatchesSearch searchString plusOnes)


setVisibleIfMatchesSearch : String -> List PlusOnePair -> Guest -> Guest
setVisibleIfMatchesSearch searchString plusOnes guest =
  { guest | isVisible = doesGuestMatchSearchString searchString plusOnes guest }


doesGuestMatchSearchString : String -> List PlusOnePair -> Guest -> Bool
doesGuestMatchSearchString searchString plusOnes guest =
  if String.isEmpty searchString || String.contains searchString (String.toLower guest.name) then
    True
  else
    False


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
  [ titleView
  , searchBarView model.searchString
  , guestListView model.guests
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
  


searchBarView : String -> Html Msg
searchBarView searchText =
  div [ class "row", id "search-bar-row" ]
  [ div [ class "col-3" ] []
  , div [ class "col-6" ]
    [ input [ class "form-control", placeholder "Search", onInput NewSearch ] []
    ]
  , div [ class "col-3" ] [ text ("'" ++ searchText ++ "'") ]
  ]


titleView : Html Msg
titleView =
  div [ class "row", id "title-row" ]
  [ div [ class "col-12"]
    [ h1 [] [ text "RSVP" ]
    ]
  ]

