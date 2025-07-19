using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Persistence.Seed;

public static class DatabaseSeed
{
    private static void SeedCountries(iCinemaDbContext context)
    {
        if (!context.Countries.Any())
        {
            var countries = new List<Country>
            {
                new Country { Id = SeedConstants.Countries.BosniaAndHerzegovina, Name = "Bosna i Hercegovina" },
                new Country { Id = SeedConstants.Countries.Croatia, Name = "Hrvatska" },
            };

            context.Countries.AddRange(countries);
            context.SaveChanges();
        }
    }
    private static void SeedCities(iCinemaDbContext context)
    {
        if (!context.Cities.Any())
        {
            var cities = new List<City>
            {
                new City { Id = SeedConstants.Cities.Sarajevo, Name = "Sarajevo", CountryId = SeedConstants.Countries.BosniaAndHerzegovina },
                new City { Id = SeedConstants.Cities.Mostar, Name = "Mostar", CountryId = SeedConstants.Countries.BosniaAndHerzegovina },
                new City { Id = SeedConstants.Cities.BanjaLuka, Name = "Banja Luka", CountryId = SeedConstants.Countries.BosniaAndHerzegovina },
                new City { Id = SeedConstants.Cities.Zagreb, Name = "Zagreb", CountryId = SeedConstants.Countries.Croatia },
                new City { Id = SeedConstants.Cities.Split, Name = "Split", CountryId = SeedConstants.Countries.Croatia },
                new City { Id = SeedConstants.Cities.Pula, Name = "Pula", CountryId = SeedConstants.Countries.Croatia },
            };

            context.Cities.AddRange(cities);
            context.SaveChanges();
        }
    }
    private static void SeedRoles(iCinemaDbContext context)
    {
        if (!context.Roles.Any())
        {
            var roles = new List<Role>
            {
                new Role
                {
                    Id = Guid.NewGuid(),
                    Name = "Admin",
                },
                new Role
                {
                    Id = Guid.NewGuid(),
                    Name = "User",
                },
                new Role
                {
                    Id = Guid.NewGuid(),
                    Name = "Staff"
                }
            };

            context.Roles.AddRange(roles);
            context.SaveChanges();
        }
    }
    private static void SeedGenres(iCinemaDbContext context)
    {
        var genres = new List<Genre>
        {
            new Genre { Id = Guid.NewGuid(), Name = "Action"},
            new Genre { Id = Guid.NewGuid(), Name = "Comedy"}
        };
        
        context.Genres.AddRange(genres);
        context.SaveChanges();
    }
    public static void Seed(iCinemaDbContext context)
    {
        SeedCountries(context);
        SeedCities(context);
        SeedRoles(context);
        SeedGenres(context);
    }
}