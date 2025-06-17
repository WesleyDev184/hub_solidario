FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

COPY . /source

WORKDIR /source

ARG TARGETARCH

RUN --mount=type=cache,id=nuget,target=/root/.nuget/packages \
    dotnet publish -a ${TARGETARCH/amd64/x64} --use-current-runtime --self-contained false -o /app

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final

ENV ASPNETCORE_ENVIRONMENT=$ASPNETCORE_ENVIRONMENT \
    SUPABASE_DATABASE=$SUPABASE_DATABASE \
    API_KEY=$API_KEY 

WORKDIR /app

COPY --from=build /app .

USER $APP_UID

ENTRYPOINT ["dotnet", "mrx_back.dll"]