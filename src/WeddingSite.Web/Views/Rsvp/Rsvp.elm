import Browser
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (class, id, placeholder, type_)
import Html.Events exposing (onClick)


main =
  Browser.sandbox { init = init, update = update, view = view }


-- MODEL

type GuestStatus
  = Unregistered
  | Attending
  | NotAttending

type alias Guest =
  { name: String
  , status: GuestStatus
  , selected: Bool
  }

createGuest : String -> Guest
createGuest name =
  { name = name, status = Unregistered, selected = False }

initialGuests : List Guest
initialGuests =
  [ createGuest "John Doe"
  , createGuest "Jane Doe"
  , createGuest "Philip J Fry"
  , createGuest "Leela"
  , createGuest "Zap"
  , createGuest "Kip"
  , createGuest "Hermes"
  , createGuest "Bender"
  , createGuest "Amy"
  ]

type alias Model =
  { guests: List Guest
  }

init : Model
init =
  { guests = initialGuests
  }


-- UPDATE

type Msg = Increment

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      model


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
  div [ class "guest-name" ]
  [ button [ class "btn btn-outline-primary", type_ "button" ]
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
  [ div [ class "col-2" ] []
  , div [ class "col-8" ]
    [ input [ class "form-control", placeholder "Search" ] []
    ]
  , div [ class "col-2" ] []
  ]


titleView : Html Msg
titleView =
  div [ class "row", id "title-row" ]
  [ div [ class "col-12"]
    [ h1 [] [ text "RSVP" ]
    ]
  ]

