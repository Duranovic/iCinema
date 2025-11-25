# Use the official .NET 9 SDK image for building
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# Copy solution and project files
COPY iCinema.sln ./
COPY iCinema.Api/iCinema.Api.csproj iCinema.Api/
COPY iCinema.Application/iCinema.Application.csproj iCinema.Application/
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

# Install OpenSSL for certificate generation
RUN apt-get update && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

# Generate a self-signed certificate for HTTPS with SAN (Subject Alternative Names)
# This allows the certificate to work with both localhost and IP addresses
RUN openssl req -x509 -newkey rsa:4096 -keyout /app/https-dev.key -out /app/https-dev.crt -days 365 -nodes \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.local,IP:127.0.0.1,IP:192.168.100.220,IP:192.168.100.221"

# Create uploads directory with proper permissions
RUN mkdir -p /app/uploads && chmod 755 /app/uploads

# Copy published application
COPY --from=build /app/publish .

# Expose ports
EXPOSE 7026
EXPOSE 5218

# Set entrypoint
ENTRYPOINT ["dotnet", "iCinema.Api.dll"]
