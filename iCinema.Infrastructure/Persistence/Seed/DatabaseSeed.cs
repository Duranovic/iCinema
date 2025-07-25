using iCinema.Infrastructure.Identity;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.AspNetCore.Identity;

namespace iCinema.Infrastructure.Persistence.Seed;

public static class DatabaseSeed
{
    private static void SeedCountries(iCinemaDbContext context)
    {
        if (context.Countries.Any()) return;
        
        var countries = new List<Country>
        {
            new Country { Id = SeedConstants.Countries.BosniaAndHerzegovina, Name = "Bosna i Hercegovina" },
            new Country { Id = SeedConstants.Countries.Croatia, Name = "Hrvatska" },
        };

        context.Countries.AddRange(countries);
        context.SaveChanges();
    }
    private static void SeedCities(iCinemaDbContext context)
    {
        if (context.Cities.Any()) return;
        
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
    private static async Task SeedRoles(RoleManager<ApplicationRole> roleManager)
    {
        var roles = new[] { "Admin", "Customer", "Staff" };
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
                await roleManager.CreateAsync(new ApplicationRole { Name = role });
        }
    }

    private static async Task SeedUsers(iCinemaDbContext context, UserManager<ApplicationUser> userManager)
    {
        async Task CreateUserAsync(string email, string password, string role)
        {
            var user = await userManager.FindByEmailAsync(email);
            if (user == null)
            {
                user = new ApplicationUser
                {
                    UserName = email,
                    Email = email,
                    EmailConfirmed = true
                };
                var result = await userManager.CreateAsync(user, password);
                if (!result.Succeeded)
                    throw new Exception($"Failed to create user {email}: {string.Join(", ", result.Errors.Select(e => e.Description))}");

                await userManager.AddToRoleAsync(user, role);
            }
        }
        
        await CreateUserAsync("admin@icinema.com", "Admin@12345", "Admin");
        await CreateUserAsync("staff@icinema.com", "Staff@12345", "Staff");
        await CreateUserAsync("customer@icinema.com", "Customer@12345", "Customer");
    }
    
    private static void SeedGenres(iCinemaDbContext context)
    {
        if (context.Genres.Any()) return;
        
        var genres = new List<Genre>
        {
            new Genre { Id = Guid.NewGuid(), Name = "Action"},
            new Genre { Id = Guid.NewGuid(), Name = "Comedy"}
        };
        
        context.Genres.AddRange(genres);
        context.SaveChanges();
    }
    public static async Task SeedAsync(iCinemaDbContext context, UserManager<ApplicationUser> userManager,  RoleManager<ApplicationRole> roleManager)
    {
        SeedCountries(context);
        SeedCities(context);
        SeedGenres(context);
        await SeedRoles(roleManager);
        await SeedUsers(context, userManager);
    }
}