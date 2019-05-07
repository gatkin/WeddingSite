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
EXPOSE 80
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT [ "dotnet", "WeddingSite.dll" ]
