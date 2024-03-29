# Build the buildtime image
FROM microsoft/dotnet:sdk AS build-env

# Grab build time arguments and make them available as environment variables
ARG FIREBASE_PROJECT_ID
ARG FIREBASE_PRIVATE_KEY_ID
ARG FIREBASE_PRIVATE_KEY
ARG FIREBASE_CLIENT_EMAIL
ARG FIREBASE_CLIENT_ID
ARG FIREBASE_AUTH_URI
ARG FIREBASE_TOKEN_URI
ARG FIREBASE_AUTH_PROVIDER_CERT_URL
ARG FIREBASE_CLIENT_CERT_URL

ENV FIREBASE_PROJECT_ID ${FIREBASE_PROJECT_ID}
ENV FIREBASE_PRIVATE_KEY_ID ${FIREBASE_PRIVATE_KEY_ID}
ENV FIREBASE_PRIVATE_KEY ${FIREBASE_PRIVATE_KEY}
ENV FIREBASE_CLIENT_EMAIL ${FIREBASE_CLIENT_EMAIL}
ENV FIREBASE_CLIENT_ID ${FIREBASE_CLIENT_ID}
ENV FIREBASE_AUTH_URI ${FIREBASE_AUTH_URI}
ENV FIREBASE_TOKEN_URI ${FIREBASE_TOKEN_URI}
ENV FIREBASE_AUTH_PROVIDER_CERT_URL ${FIREBASE_AUTH_PROVIDER_CERT_URL}
ENV FIREBASE_CLIENT_CERT_URL ${FIREBASE_CLIENT_CERT_URL}

WORKDIR /app
COPY ./ ./

# Download the Elm toolchain and build the Elm sources
RUN wget -qO - "https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz" | tar -zxC /usr/local/bin/
RUN ./src/BuildScripts/build-elm-sources.sh

# Build the firebase auth file
RUN python ./src/BuildScripts/create_firebase_auth.py FirebaseAuth.json

# Build the backend and restore in separate layers
ENV MAIN_PROJECT=src/WeddingSite.Web
RUN dotnet restore ${MAIN_PROJECT}
RUN dotnet build --configuration Release ${MAIN_PROJECT}
RUN dotnet publish --configuration Release -o out ${MAIN_PROJECT}

# Build the runtime image
FROM microsoft/dotnet:aspnetcore-runtime

WORKDIR /app
COPY --from=build-env /app/src/WeddingSite.Web/out .

# Make the firebase authentication information available to the application
COPY --from=build-env /app/FirebaseAuth.json /app/FirebaseAuth.json
ENV GOOGLE_APPLICATION_CREDENTIALS=/app/FirebaseAuth.json

# Create an app user so our program doesn't run as root.
RUN groupadd -r app && \
    useradd -r -g app -d /home/app -s /sbin/nologin -c "Docker image user" app
RUN chown -R app:app /app
USER app

CMD dotnet WeddingSite.Web.dll --urls=http://*:$PORT
