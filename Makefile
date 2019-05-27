TAG=wedding-site
PORT=5005

build:
	docker build --tag=${TAG} .

heroku-deploy: heroku-push
	heroku container:release web

heroku-init:
	heroku login && heroku container:login

heroku-push: heroku-init
	heroku container:push web

run: build
	docker run -e PORT=${PORT} -p ${PORT}:${PORT} ${TAG}:latest
