WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=${WEB_DIRECTORY}/Views/Rsvp/Rsvp.elm
elm make ${ELM_FILE_PATH} --optimize --output=${WEB_DIRECTORY}/wwwroot/elm/rsvp.elm.js
