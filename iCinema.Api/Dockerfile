# Use the official .NET 9 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and project files
COPY iCinema.sln ./
COPY iCinema.Api/iCinema.Api.csproj iCinema.Api/
COPY iCinema.Application/iCinema.Application.csproj iCinema.Application/
COPY iCinema.Domain/iCinema.Domain.csproj iCinema.Domain/
COPY iCinema.Infrastructure/iCinema.Infrastructure.csproj iCinema.Infrastructure/

# Restore dependencies
RUN dotnet restore

# Copy source code
COPY . .

# Build the application
WORKDIR /src/iCinema.Api
RUN dotnet publish -c Release -o /app/publish

# Use the official .NET 9 runtime image
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS runtime
WORKDIR /app

# Create uploads directory with proper permissions
RUN mkdir -p /app/uploads && chmod 755 /app/uploads

# Copy published application
COPY --from=build /app/publish .

# Expose port
EXPOSE 8080

# Set entrypoint
ENTRYPOINT ["dotnet", "iCinema.Api.dll"]
