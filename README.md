# iCinema - Sistem za Upravljanje Kinom

iCinema je kompletan sistem za upravljanje kinom koji se sastoji od:
- **Backend API** (.NET 8) - RESTful API sa SignalR podrškom
- **Desktop aplikacija** (Flutter) - Administratorska aplikacija
- **Mobile aplikacija** (Flutter) - Klijentska aplikacija za korisnike

## Pokretanje Aplikacije

### Preduvjeti

- **Docker i Docker Compose** (preporučeno - sve radi "out of the box")
- ILI .NET 8 SDK + Flutter SDK (3.5.0+) + SQL Server za lokalno pokretanje

---

## 🐳 Pokretanje sa Docker-om (Preporučeno - Out of the Box)

**Sve je konfigurisano i radi bez dodatnih izmjena koda, linkova, portova ili connection stringova!**

### Jednostavno Pokretanje

1. Pokreni sve servise (SQL Server, API, RabbitMQ):
   ```bash
   docker-compose up -d
   ```

2. Sačekaj da se sve pokrene (oko 30-60 sekundi):
   ```bash
   docker-compose logs -f api
   ```
   
   Kada vidiš poruku da je API pokrenut, sve je spremno!

3. API će biti dostupan na:
   - HTTP: `http://localhost:5218`
   - HTTPS: `https://localhost:7026`

### Što se automatski dešava:

✅ **Baza podataka** se automatski kreira (`docker-init.sql`)  
✅ **Migracije** se automatski primjenjuju pri pokretanju API-ja  
✅ **Seed podaci** se automatski dodaju (korisnici, filmovi, žanrovi, itd.)  
✅ **Connection string** je već konfigurisan u `docker-compose.yml`  
✅ **Portovi** su već konfigurisani (5218, 7026)  
✅ **Nema potrebe za mijenjanjem koda ili konfiguracija**

### Upravljanje

**Zaustavljanje:**
```bash
docker-compose down
```

**Brisanje svih podataka (fresh start):**
```bash
docker-compose down -v
docker-compose up -d
```

**Pregled logova:**
```bash
docker-compose logs -f
```

---

## 💻 Lokalno Pokretanje (Bez Docker-a)

### Preduvjeti

- .NET 8 SDK
- Flutter SDK (3.5.0+)
- SQL Server (lokalno)
- Node.js (za SignalR client, opciono)

### Backend API

1. Navigiraj u `iCinema.Api` folder
2. **Ažuriraj connection string u `appsettings.json`** (ako je potrebno):
   ```json
   "ConnectionStrings": {
     "DefaultConnection": "Data Source=localhost,1433;Database=iCinema;user=sa;password=YourPassword;TrustServerCertificate=True;"
   }
   ```
   **Napomena:** Ako koristiš default SQL Server konfiguraciju (localhost, sa, password iz appsettings.json), nije potrebno mijenjati ništa.

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
   
   **Napomena:** Aplikacija je konfigurisana da radi bez dodatnih izmjena koda. Sve konfiguracije se nalaze u `appsettings.json` fajlu.

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
- **Default vrijednost:** `http://localhost:5218` (radi bez dodatnih izmjena ako je API pokrenut lokalno)
- API URL se može konfigurisati kroz `--dart-define` bez mijenjanja koda:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://your-api-url:5218
  ```

### Mobile Aplikacija

1. Navigiraj u `iCinema.UI/icinema_mobile_client` folder
2. Instaliraj dependencies:
   ```bash
   flutter pub get
   ```
3. Pokreni aplikaciju:
   ```bash
   flutter run
   ```

**Konfiguracija API URL-a:**
- **Default vrijednost:** `http://10.0.2.2:5218` (radi bez dodatnih izmjena za Android Emulator)
- Za fizički Android uređaj, API URL se može konfigurisati kroz `--dart-define` bez mijenjanja koda:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://your-computer-ip:5218
  ```

## Korisnički Podaci za Pristup Aplikaciji

**Napomena:** Ovi korisnici se automatski kreiraju pri prvom pokretanju (seed podaci).

### Desktop Verzija

**Korisničko ime:** `admin@icinema.com`  
**Lozinka:** `test`  
**Uloga:** Admin

### Mobilna Verzija

**Korisničko ime:** `customer@icinema.com`  
**Lozinka:** `test`  
**Uloga:** Customer

**Korisničko ime:** `staff@icinema.com`  
**Lozinka:** `test`  
**Uloga:** Staff

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

Svi konfiguracijski podaci se nalaze u konfiguracijskim fajlovima i mogu se mijenjati **bez modifikacije programskog koda**:

- **Backend**: `iCinema.Api/appsettings.json` - connection string, JWT keys, itd.
- **Mobile**: Default API URL je `http://10.0.2.2:5218` (za Android Emulator)
- **Desktop**: Default API URL je `http://localhost:5218` (za lokalni API)

**Konfiguracija bez mijenjanja koda:**
- **Backend**: Mijenjaj `appsettings.json` fajl
- **Flutter aplikacije**: Koristi `--dart-define` flag pri build-u ili run-u:
  ```bash
  flutter run --dart-define=API_BASE_URL=http://your-api-url:5218
  ```

**Važno:** 
- **Docker opcija** je potpuno "out of the box" - samo `docker-compose up -d` i sve radi bez ikakvih izmjena
- Aplikacija je konfigurisana da radi "out of the box" sa default vrijednostima
- Sve konfiguracije se mogu mijenjati bez modifikacije source code-a
- Connection strings, API keys i portovi se ne hardcoduju u kodu, već se čuvaju u konfiguracijskim fajlovima
- Migracije i seed podaci se automatski primjenjuju pri pokretanju (bez dodatnih komandi)

## Dokumentacija

- **Recommender Sistem**: `recommender-dokumentacija.pdf` - Dokumentacija sistema preporuke filmova

## Tehnologije

- **Backend**: .NET 8, Entity Framework Core, SignalR
- **Frontend**: Flutter, Dart
- **Database**: SQL Server
- **State Management**: Flutter Bloc
- **Dependency Injection**: GetIt, Injectable

