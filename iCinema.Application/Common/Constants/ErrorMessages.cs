namespace iCinema.Application.Common.Constants;

public static class ErrorMessages
{
    // General errors
    public const string DeleteError = "Greška pri brisanju";
    public const string DeleteInUse = "Zapis je u upotrebi i ne može biti obrisan.";
    public const string ValidationError = "Greška validacije";
    public const string BusinessRuleViolation = "Povreda poslovnih pravila";
    public const string InternalServerError = "Interna greška servera";
    public const string UnexpectedError = "Dogodila se neočekivana greška.";
    public const string InvalidCredentials = "Nevažeći podaci za prijavu.";
    public const string UnauthorizedAccess = "Nemate dozvolu za pristup administratorskoj aplikaciji.";
    
    // Movie/Content errors
    public const string RatingValueRange = "Ocjena mora biti između 1 i 5";
    public const string NoCastItems = "Nisu navedeni članovi glumačke ekipe";
    public const string TitleRequired = "Naslov je obavezan.";
    public const string TitleMaxLength = "Naslov ne može biti duži od 200 karaktera.";
    public const string YearRange = "Godina mora biti između 1900 i sljedeće godine.";
    public const string DescriptionRequired = "Opis je obavezan.";
    public const string DescriptionMaxLength = "Opis ne može biti duži od 1000 karaktera.";
    public const string GenreRequired = "Morate odabrati barem jedan žanr.";
    
    // Genre errors
    public const string GenreNameRequired = "Naziv žanra je obavezan.";
    public const string GenreNameMaxLength = "Naziv žanra ne može biti duži od 50 karaktera.";
    
    // Country errors
    public const string CountryNameRequired = "Naziv države je obavezan.";
    public const string CountryNameMaxLength = "Naziv države ne može biti duži od 100 karaktera.";
    
    // City errors
    public const string CityNameRequired = "Naziv grada je obavezan.";
    public const string CityNameMaxLength = "Naziv grada ne može biti duži od 100 karaktera.";
    public const string CountryIdRequired = "CountryId mora biti važeći GUID.";
    
    // Cinema errors
    public const string CinemaNameRequired = "Naziv bioskopa je obavezan.";
    public const string CinemaNameMaxLength = "Naziv bioskopa ne može biti duži od 100 karaktera.";
    public const string AddressRequired = "Adresa je obavezna.";
    public const string AddressMaxLength = "Adresa ne može biti duža od 200 karaktera.";
    public const string CityIdRequired = "CityId je obavezan.";
    public const string InvalidEmailFormat = "Nevažeći format e-pošte.";
    public const string InvalidPhoneFormat = "Nevažeći format telefonskog broja.";
    
    // Projection errors
    public const string MovieIdRequired = "MovieId je obavezan.";
    public const string HallIdRequired = "HallId je obavezan.";
    public const string StartTimeRequired = "Vrijeme početka je obavezno.";
    public const string StartTimeMustBeFuture = "Vrijeme početka mora biti u budućnosti.";
    public const string ProjectionAlreadyStarted = "Ne možete ažurirati projekciju koja je već počela.";
    public const string ProjectionNotFound = "Projekcija nije pronađena";
    
    // Hall errors
    public const string HallNameRequired = "Naziv sale je obavezan.";
    public const string RowsCountMustBeGreaterThanZero = "Broj redova mora biti veći od nule.";
    public const string SeatsPerRowMustBeGreaterThanZero = "Broj sjedala po redu mora biti veći od nule.";
    public const string CinemaIdRequired = "CinemaId je obavezan.";
    
    // Ticket/Reservation errors
    public const string TicketNotFound = "Karta nije pronađena ili nije dostupna";
    public const string TokenRequired = "Token je obavezan";
    public const string ReservationNotFound = "Rezervacija nije pronađena";
    
    // Helper method for capacity message
    public static string CapacityExceeded(int maxCapacity) => 
        $"Ukupni kapacitet (Broj redova × Sjedala po redu) ne smije premašiti {maxCapacity} sjedala.";
}

