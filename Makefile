TAG=wedding-site
PORT=5005
WEB_DIRECTORY=src/WeddingSite.Web

build-docker: build-elm
	docker build --tag=${TAG} .

build-elm:
	elm make $(WEB_DIRECTORY)/Views/Rsvp/Rsvp.elm --output=$(WEB_DIRECTORY)/wwwroot/elm/rsvp.elm.js

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
