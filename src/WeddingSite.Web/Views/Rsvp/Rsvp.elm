import Browser
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (class, id, placeholder, type_)
import Html.Events exposing (onClick)


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
  }

createGuest : String -> Int -> Guest
createGuest name guestId =
  { id = guestId, name = name, status = Unregistered, isSelected = False }

initialGuests : List Guest
initialGuests =
  [ createGuest "John Doe" 1
  , createGuest "Jane Doe" 2
  , createGuest "Philip J Fry" 3
  , createGuest "Leela" 4
  , createGuest "Zap" 5
  , createGuest "Kip" 6
  , createGuest "Hermes" 7
  , createGuest "Bender" 8
  , createGuest "Amy" 9
  , createGuest "Zoidberg" 10
  ]

type alias Model =
  { guests: List Guest
  }

init : Model
init =
  { guests = initialGuests
  }


-- UPDATE

type Msg = SelectGuest GuestId

update : Msg -> Model -> Model
update msg model =
  case msg of
    SelectGuest guestId ->
      onGuestSelected guestId model


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


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "container-fluid" ]
  [ titleView
  , searchBarView
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
    guestViews = List.map guestView guests
  in
    div [ class "row" ]
    [ div [ class "col-2" ] []
    , div [ class "col-8", id "guest-list-container" ]  guestViews
    , div [ class "col-2" ]  []
    ]
  


searchBarView : Html Msg
searchBarView =
  div [ class "row", id "search-bar-row" ]
  [ div [ class "col-3" ] []
  , div [ class "col-6" ]
    [ input [ class "form-control", placeholder "Search" ] []
    ]
  , div [ class "col-3" ] []
  ]


titleView : Html Msg
titleView =
  div [ class "row", id "title-row" ]
  [ div [ class "col-12"]
    [ h1 [] [ text "RSVP" ]
    ]
  ]

