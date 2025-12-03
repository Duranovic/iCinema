# iCinema - Sistem za Upravljanje Kinom

iCinema je kompletan sistem za upravljanje kinom koji se sastoji od:
- **Backend API** (.NET 8) - RESTful API sa SignalR podrškom
- **Desktop aplikacija** (Flutter) - Administratorska aplikacija
- **Mobile aplikacija** (Flutter) - Klijentska aplikacija za korisnike

## Pokretanje Aplikacije

### Preduvjeti

- .NET 8 SDK
- Flutter SDK (3.5.0+)
- SQL Server (lokalno ili Docker)
- Node.js (za SignalR client, opciono)

### Backend API

1. Navigiraj u `iCinema.Api` folder
2. Ažuriraj connection string u `appsettings.json`:
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Data Source=localhost,1433;Database=iCinema;user=sa;password=YourPassword;TrustServerCertificate=True;"
   }
   ```
3. Pokreni migracije:
   ```bash
   cd iCinema.Infrastructure
   dotnet ef database update --project ../iCinema.Infrastructure --startup-project ../iCinema.Api
   ```
4. Pokreni API:
   ```bash
   cd iCinema.Api
   dotnet run
   ```
   
   API će biti dostupan na:
   - HTTP: `http://localhost:5218`
   - HTTPS: `https://localhost:7026`

### Desktop Aplikacija

1. Navigiraj u `iCinema.UI/icinema_desktop` folder
2. Instaliraj dependencies:
   ```bash
   flutter pub get
   ```
3. Pokreni aplikaciju:
   ```bash
   flutter run -d macos
   # ili za Windows:
   flutter run -d windows
   ```

**Konfiguracija API URL-a:**
- API URL se može konfigurisati kroz `--dart-define`:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://localhost:5218
  ```
- Default vrijednost: `http://localhost:5218`

### Mobile Aplikacija

1. Navigiraj u `iCinema.UI/icinema_mobile_client` folder
2. Instaliraj dependencies:
   ```bash
   flutter pub get
   ```
3. Za Android Emulator, API URL je automatski postavljen na `http://10.0.2.2:5218`
4. Pokreni aplikaciju:
   ```bash
   flutter run
   ```

**Konfiguracija API URL-a:**
- API URL se može konfigurisati kroz `--dart-define`:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:5218
  ```
- Default vrijednost za Android Emulator: `http://10.0.2.2:5218`

## Korisnički Podaci za Pristup Aplikaciji

### Desktop Verzija

**Korisničko ime:** `admin@icinema.com`  
**Lozinka:** `test`

### Mobilna Verzija

**Korisničko ime:** `customer@icinema.com`  
**Lozinka:** `test`

**Korisničko ime:** `staff@icinema.com`  
**Lozinka:** `test`

## Build Aplikacija

### Android APK

```bash
cd iCinema.UI/icinema_mobile_client
flutter clean
flutter build apk --release
```

APK fajl se nalazi na: `build/app/outputs/flutter-apk/app-release.apk`

### Windows EXE

```bash
cd iCinema.UI/icinema_desktop
flutter clean
flutter build windows --release
```

EXE fajl se nalazi na: `build/windows/x64/runner/Release/iCinema.exe`

## Struktura Projekta

```
iCinema/
├── iCinema.Api/              # Backend API
├── iCinema.Application/      # Business logic
├── iCinema.Domain/           # Domain models
├── iCinema.Infrastructure/   # Data access, EF Core
└── iCinema.UI/
    ├── icinema_mobile_client/  # Flutter mobile app
    ├── icinema_desktop/        # Flutter desktop app
    └── icinema_shared/         # Shared Flutter code
```

## Konfiguracijski Podaci

Svi konfiguracijski podaci se nalaze u konfiguracijskim fajlovima:

- **Backend**: `iCinema.Api/appsettings.json`
- **Mobile**: `iCinema.UI/icinema_mobile_client/lib/app/config/app_config.dart`
- **Desktop**: `iCinema.UI/icinema_desktop/lib/app/di/network_module.dart`

Konfiguracija se može mijenjati kroz:
- Environment varijable
- `--dart-define` flag za Flutter aplikacije
- `appsettings.json` za backend

**Važno:** Konfiguracijski podaci (connection strings, API keys, itd.) se **ne hardcoduju** u source code-u, već se čuvaju u konfiguracijskim fajlovima.

## Dokumentacija

- **Recommender Sistem**: `recommender-dokumentacija.pdf` - Dokumentacija sistema preporuke filmova

## Tehnologije

- **Backend**: .NET 8, Entity Framework Core, SignalR
- **Frontend**: Flutter, Dart
- **Database**: SQL Server
- **State Management**: Flutter Bloc
- **Dependency Injection**: GetIt, Injectable

