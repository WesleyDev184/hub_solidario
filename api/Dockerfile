# Building a .NET 8.0 application
FROM mcr.microsoft.com/dotnet/sdk:8.0-alpine AS build

COPY . /source

WORKDIR /source

# Clear nuget cache and restore
RUN dotnet nuget locals all --clear
RUN dotnet restore --verbosity normal

# Publish for x64 architecture
RUN dotnet publish -c Release -o /app --no-restore --verbosity normal

# Final image
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS final

WORKDIR /app

COPY --from=build /app .

# define a porta interna e expõe para fora do container
ENV ASPNETCORE_URLS=http://+:5001
EXPOSE 5001

# Remove USER $APP_UID que pode causar problemas
# USER $APP_UID

ENTRYPOINT ["dotnet", "api.dll"]