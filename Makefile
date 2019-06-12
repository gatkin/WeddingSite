TAG=wedding-site
PORT=5005
WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=$(WEB_DIRECTORY)/Views/Rsvp/Rsvp.elm

build-docker:
	./src/BuildScripts/build-docker.sh

build-elm:
	./src/BuildScripts/build-elm-sources.sh

deploy-heroku:
	heroku container:release web

per-commit: deploy-heroku

push-heroku: build-docker
	./src/BuildScripts/push-heroku.sh

run: build-docker
	docker run -e PORT=$(PORT) -p $(PORT):$(PORT) $(TAG):latest

watch:
	dotnet watch --project src/WeddingSite.Web/WeddingSite.Web.csproj run

watch-elm: build-elm
	when-changed $(ELM_FILE_PATH) make build-elm
