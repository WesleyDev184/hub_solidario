# Building a .NET 8.0 application
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

COPY . /source

WORKDIR /source

ARG TARGETARCH

RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
    dotnet publish -a ${TARGETARCH/amd64/x64} --use-current-runtime --self-contained false -o /app

# Final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final

WORKDIR /app

COPY --from=build /app .

# define a porta interna e expõe para fora do container
ENV ASPNETCORE_URLS=http://+:5001
EXPOSE 5001

USER $APP_UID

ENTRYPOINT ["dotnet", "api.dll"]