# Compiles all Elm sources to Javascript
WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=${WEB_DIRECTORY}/wwwroot/elm/index.elm
elm make ${ELM_FILE_PATH} --optimize --output=${WEB_DIRECTORY}/wwwroot/elm/index.elm.js
