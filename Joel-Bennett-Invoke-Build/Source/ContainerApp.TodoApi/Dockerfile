# syntax=docker/dockerfile:1
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /source

# copy csproj and restore ahead of time for caching
COPY *.csproj .
RUN dotnet restore --ucr

# Copy everything else and build
ARG VERSION=1.0.0
ARG CONFIGURATION=Release
COPY . .
RUN dotnet publish -o output --no-restore --ucr --no-self-contained -c ${CONFIGURATION} -p Version=${VERSION}

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS runtime
WORKDIR /api
COPY --link --from=build /source/output .

# Set port
# ENV ASPNETCORE_URLS="http://0.0.0.0:5000"

ENTRYPOINT ["dotnet", "ContainerApp.TodoApi.dll"]