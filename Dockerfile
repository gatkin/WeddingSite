# Build the buildtime image
FROM microsoft/dotnet:sdk AS build-env
WORKDIR /app

# Copy csproj and restore as distinct layers
COPY ./src ./
RUN dotnet restore
RUN dotnet build -c Release
RUN dotnet publish -c Release -o out

# Build the runtime image
FROM microsoft/dotnet:aspnetcore-runtime

WORKDIR /app
COPY --from=build-env /app/out .

# Create an app user so our program doesn't run as root.
# RUN groupadd -r app &&\
#     useradd -r -g app -d /home/app -s /sbin/nologin -c "Docker image user" app
# RUN chown -R app:app /app
# USER app

#EXPOSE $PORT
#ENV ASPNETCORE_URLS="http://*:$PORT"

CMD dotnet WeddingSite.dll --urls=http://*:$PORT
