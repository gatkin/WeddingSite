TAG=wedding-site
PORT=5005
WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=$(WEB_DIRECTORY)/Views/Rsvp/Rsvp.elm
HEROKU_REGISTRY=registry.heroku.com/mckayandgreg/web

build-docker:
	echo $(HEROKU_API_KEY) | docker login -u _ --password-stdin $(HEROKU_REGISTRY) && \
	docker build \
	--build-arg FIREBASE_PROJECT_ID="$(FIREBASE_PROJECT_ID)" \
	--build-arg FIREBASE_PRIVATE_KEY_ID="$(FIREBASE_PRIVATE_KEY_ID)" \
	--build-arg FIREBASE_PRIVATE_KEY="$(FIREBASE_PRIVATE_KEY)" \
	--build-arg FIREBASE_CLIENT_EMAIL="$(FIREBASE_CLIENT_EMAIL)" \
	--build-arg FIREBASE_CLIENT_ID="$(FIREBASE_CLIENT_ID)" \
	--build-arg FIREBASE_AUTH_URI="$(FIREBASE_AUTH_URI)" \
	--build-arg FIREBASE_TOKEN_URI="$(FIREBASE_TOKEN_URI)" \
	--build-arg FIREBASE_AUTH_PROVIDER_CERT_URL="$(FIREBASE_AUTH_PROVIDER_CERT_URL)" \
	--build-arg FIREBASE_CLIENT_CERT_URL="$(FIREBASE_CLIENT_CERT_URL)" \
	--tag=$(TAG) .

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
