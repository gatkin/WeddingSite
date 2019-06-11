TAG=wedding-site
PORT=5005
WEB_DIRECTORY=src/WeddingSite.Web
ELM_FILE_PATH=${WEB_DIRECTORY}/Views/Rsvp/Rsvp.elm
HEROKU_REGISTRY=registry.heroku.com/mckayandgreg/web

build-docker: build-elm
	docker build \
	--build-arg FIREBASE_PROJECT_ID="${FIREBASE_PROJECT_ID}" \
	--build-arg FIREBASE_PRIVATE_KEY_ID="${FIREBASE_PRIVATE_KEY_ID}" \
	--build-arg FIREBASE_PRIVATE_KEY="${FIREBASE_PRIVATE_KEY}" \
	--build-arg FIREBASE_CLIENT_EMAIL="${FIREBASE_CLIENT_EMAIL}" \
	--build-arg FIREBASE_CLIENT_ID="${FIREBASE_CLIENT_ID}" \
	--build-arg FIREBASE_AUTH_URI="${FIREBASE_AUTH_URI}" \
	--build-arg FIREBASE_TOKEN_URI="${FIREBASE_TOKEN_URI}" \
	--build-arg FIREBASE_AUTH_PROVIDER_CERT_URL="${FIREBASE_AUTH_PROVIDER_CERT_URL}" \
	--build-arg FIREBASE_CLIENT_CERT_URL="${FIREBASE_CLIENT_CERT_URL}" \
	--tag=${TAG} .

build-elm:
	elm make ${ELM_FILE_PATH} --optimize --output=${WEB_DIRECTORY}/wwwroot/elm/rsvp.elm.js

heroku-deploy: heroku-push
	heroku container:release web

heroku-init:
	heroku login && heroku container:login

heroku-push: heroku-init build-docker
	docker tag ${TAG}:latest ${HEROKU_REGISTRY} && \
	docker push ${HEROKU_REGISTRY}

per-commit: setup build-docker

run: build-docker
	docker run -e PORT=${PORT} -p ${PORT}:${PORT} ${TAG}:latest

setup:
	sudo npm install -g elm --unsafe-perm=true --allow-root

watch:
	dotnet watch --project src/WeddingSite.Web/WeddingSite.Web.csproj run

watch-elm: build-elm
	when-changed ${ELM_FILE_PATH} make build-elm
