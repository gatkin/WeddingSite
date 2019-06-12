TAG=wedding-site
PORT=5005
WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=$(WEB_DIRECTORY)/Views/Rsvp/Rsvp.elm
HEROKU_REGISTRY=registry.heroku.com/mckayandgreg/web

build-docker:
	./src/BuildScripts/build-docker.sh

build-elm:
	./src/BuildScripts/build-elm-sources.sh

heroku-deploy: heroku-push
	./src/BuildScripts/deploy-heroku.sh

heroku-push: build-docker
	docker login -u _ -p $(HEROKU_API_KEY) $(HEROKU_REGISTRY) && \
	docker tag $(TAG):latest $(HEROKU_REGISTRY) && \
	docker push $(HEROKU_REGISTRY)

per-commit: heroku-deploy

run: build-docker
	docker run -e PORT=$(PORT) -p $(PORT):$(PORT) $(TAG):latest

watch:
	dotnet watch --project src/WeddingSite.Web/WeddingSite.Web.csproj run

watch-elm: build-elm
	when-changed $(ELM_FILE_PATH) make build-elm
