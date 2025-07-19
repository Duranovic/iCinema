using Microsoft.EntityFrameworkCore;
using iCinema.Infrastructure.Persistence.Models;

namespace iCinema.Infrastructure.Persistence.Configurations;

public static class DatabaseSeed
{
    public static void Seed(ModelBuilder modelBuilder)
    {
        // Seed Roles
        modelBuilder.Entity<Role>().HasData(
            new Role { Id = Guid.Parse("11111111-1111-1111-1111-111111111111"), Name = "Admin" },
            new Role { Id = Guid.Parse("22222222-2222-2222-2222-222222222222"), Name = "Client" }
        );

        // Seed Countries
        modelBuilder.Entity<Country>().HasData(
            new Country { Id = Guid.Parse("a1a1a1a1-a1a1-4a1a-a1a1-a1a1a1a1a1a1"), Name = "Bosnia and Herzegovina" },
            new Country { Id = Guid.Parse("b2b2b2b2-b2b2-4b2b-b2b2-b2b2b2b2b2b2"), Name = "Croatia" }
        );

        // Seed Cities
        modelBuilder.Entity<City>().HasData(
            new City {
                Id = Guid.Parse("c3c3c3c3-c3c3-4c3c-c3c3-c3c3c3c3c3c3"),
                Name = "Mostar",
                CountryId = Guid.Parse("a1a1a1a1-a1a1-4a1a-a1a1-a1a1a1a1a1a1")
            }
        );

        // Seed Genres
        modelBuilder.Entity<Genre>().HasData(
            new Genre { Id = Guid.Parse("d4d4d4d4-d4d4-4d4d-d4d4-d4d4d4d4d4d4"), Name = "Action" },
            new Genre { Id = Guid.Parse("e5e5e5e5-e5e5-4e5e-e5e5-e5e5e5e5e5e5"), Name = "Comedy" }
        );
    }
}