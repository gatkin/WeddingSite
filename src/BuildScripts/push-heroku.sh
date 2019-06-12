# Pushes a new image to the Heroku registry.
HEROKU_REGISTRY=registry.heroku.com/mckayandgreg/web

docker login -u _ -p $(HEROKU_API_KEY) $(HEROKU_REGISTRY) && \
docker tag $(TAG):latest $(HEROKU_REGISTRY) && \
docker push $(HEROKU_REGISTRY)
