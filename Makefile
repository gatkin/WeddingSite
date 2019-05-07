TAG=wedding-site
PORT=5005

build:
	docker build --tag=${TAG} .

run: build
	docker run -e PORT=${PORT} -p ${PORT}:${PORT} ${TAG}:latest
