TAG=wedding-site
PORT=5005
WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=$(WEB_DIRECTORY)/Views/Rsvp/Rsvp.elm

build-docker: build-elm
	docker build --tag=${TAG} .

build-elm:
	elm make $(ELM_FILE_PATH) --output=$(WEB_DIRECTORY)/wwwroot/elm/rsvp.elm.js

heroku-deploy: heroku-push
	heroku container:release web

heroku-init:
	heroku login && heroku container:login

heroku-push: heroku-init
	heroku container:push web

run: build
	docker run -e PORT=${PORT} -p ${PORT}:${PORT} ${TAG}:latest

watch:
	dotnet watch --project src/WeddingSite.Web/WeddingSite.Web.csproj run

watch-elm: build-elm
	when-changed $(ELM_FILE_PATH) make build-elm
