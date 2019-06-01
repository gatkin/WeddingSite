# Build the buildtime image
FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./src ./
RUN dotnet restore WeddingSite.Web
RUN dotnet build --configuration Release WeddingSite.Web
RUN dotnet publish --configuration Release -o out WeddingSite.Web

# Build the runtime image
FROM microsoft/dotnet:aspnetcore-runtime

WORKDIR /app
COPY --from=build-env /app/WeddingSite.Web/out .

# Create an app user so our program doesn't run as root.
RUN groupadd -r app &&\
    useradd -r -g app -d /home/app -s /sbin/nologin -c "Docker image user" app
RUN chown -R app:app /app
USER app

CMD dotnet WeddingSite.Web.dll --urls=http://*:$PORT
