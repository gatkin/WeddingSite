# Deploys the latest docker image through the Heroku API based on:
# https://devcenter.heroku.com/articles/container-registry-and-runtime#releasing-an-image

curl -n -X PATCH https://api.heroku.com/apps/mckayandgreg/formation \
  -d '{
  "updates": [
    {
      "type": "web"
    }
  ]
}' \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $HEROKU_API_KEY" \
  -H "Accept: application/vnd.heroku+json; version=3.docker-releases"