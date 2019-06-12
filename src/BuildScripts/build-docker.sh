# Builds the Docker image with all authentication secret values passed in from the
# environment variables.
docker build \
    --build-arg FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
    --build-arg FIREBASE_PRIVATE_KEY_ID="$FIREBASE_PRIVATE_KEY_ID" \
    --build-arg FIREBASE_PRIVATE_KEY="$FIREBASE_PRIVATE_KEY" \
    --build-arg FIREBASE_CLIENT_EMAIL="$FIREBASE_CLIENT_EMAIL" \
    --build-arg FIREBASE_CLIENT_ID="$FIREBASE_CLIENT_ID" \
    --build-arg FIREBASE_AUTH_URI="$FIREBASE_AUTH_URI" \
    --build-arg FIREBASE_TOKEN_URI="$FIREBASE_TOKEN_URI" \
    --build-arg FIREBASE_AUTH_PROVIDER_CERT_URL="$FIREBASE_AUTH_PROVIDER_CERT_URL" \
    --build-arg FIREBASE_CLIENT_CERT_URL="$FIREBASE_CLIENT_CERT_URL" \
    --tag=wedding-site .