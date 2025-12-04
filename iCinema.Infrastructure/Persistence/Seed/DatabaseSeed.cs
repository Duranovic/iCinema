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

            new Country { Id = SeedConstants.Countries.BosniaAndHerzegovina, Name = "Bosnia and Herzegovina" },
            new Country { Id = SeedConstants.Countries.Croatia, Name = "Croatia" },
        };

        context.Countries.AddRange(countries);
        context.SaveChanges();
    }

    private static void SeedCities(iCinemaDbContext context)
    {
        if (context.Cities.Any()) return;

        var cities = new List<City>
        {
            new City
            {
                Id = SeedConstants.Cities.Sarajevo, Name = "Sarajevo",
                CountryId = SeedConstants.Countries.BosniaAndHerzegovina
            },
            new City
            {
                Id = SeedConstants.Cities.Mostar, Name = "Mostar",
                CountryId = SeedConstants.Countries.BosniaAndHerzegovina
            },
            new City { Id = SeedConstants.Cities.Zagreb, Name = "Zagreb", CountryId = SeedConstants.Countries.Croatia },
            new City { Id = SeedConstants.Cities.Split, Name = "Split", CountryId = SeedConstants.Countries.Croatia },
            new City { Id = SeedConstants.Cities.Pula, Name = "Pula", CountryId = SeedConstants.Countries.Croatia },
        };
        context.Cities.AddRange(cities);
        context.SaveChanges();
    }

    private static void SeedProjections(iCinemaDbContext context)
    {
        // Ensure at least one cinema exists
        var cinema = context.Cinemas.FirstOrDefault();
        if (cinema == null)
        {
            cinema = new Cinema
            {
                Id = Guid.NewGuid(),
                Name = "iCinema Sarajevo",
                CityId = SeedConstants.Cities.Sarajevo,
                Address = "Maršala Tita 1",
                Email = "info@icinema.local",
                PhoneNumber = "+387 33 123 456"
            };
            context.Cinemas.Add(cinema);
            context.SaveChanges();
        }

        // Ensure at least one hall for the cinema exists
        var hall = context.Halls.FirstOrDefault(h => h.CinemaId == cinema.Id);
        if (hall == null)
        {
            hall = new Hall
            {
                Id = Guid.NewGuid(),
                CinemaId = cinema.Id,
                Name = "Hall 1",
                RowsCount = 10,
                SeatsPerRow = 14,
                HallType = "Standard",
                ScreenSize = "Large",
                IsDolbyAtmos = false
            };
            context.Halls.Add(hall);
            context.SaveChanges();
            
            // Create seats for the hall
            for (int row = 1; row <= hall.RowsCount; row++)
            {
                for (int seat = 1; seat <= hall.SeatsPerRow; seat++)
                {
                    context.Seats.Add(new Seat
                    {
                        Id = Guid.NewGuid(),
                        HallId = hall.Id,
                        RowNumber = row,
                        SeatNumber = seat
                    });
                }
            }
            context.SaveChanges();
        }
        
        // Ensure seats exist for the hall (in case hall existed but seats don't)
        if (!context.Seats.Any(s => s.HallId == hall.Id))
        {
            for (int row = 1; row <= hall.RowsCount; row++)
            {
                for (int seat = 1; seat <= hall.SeatsPerRow; seat++)
                {
                    context.Seats.Add(new Seat
                    {
                        Id = Guid.NewGuid(),
                        HallId = hall.Id,
                        RowNumber = row,
                        SeatNumber = seat
                    });
                }
            }
            context.SaveChanges();
        }

        // Helper to add a projection if it doesn't already exist at the same time
        void AddProjectionIfMissing(Guid movieId, DateTime start, decimal price, string? type = null,
            bool? subtitled = null)
        {
            var exists =
                context.Projections.Any(p => p.MovieId == movieId && p.HallId == hall.Id && p.StartTime == start);
            if (!exists)
            {
                context.Projections.Add(new Projection
                {
                    Id = Guid.NewGuid(),
                    MovieId = movieId,
                    HallId = hall.Id,
                    StartTime = start,
                    Price = price,
                    IsActive = true,
                    ProjectionType = type,
                    IsSubtitled = subtitled
                });
            }
        }

        // Seed a few upcoming shows for the seeded movies
        DateTime today = DateTime.Today;
        var movies = context.Movies
            .Where(m => new[] { "Oppenheimer", "Barbie", "Killers of the Flower Moon" }.Contains(m.Title)).ToList();
        foreach (var m in movies)
        {
            AddProjectionIfMissing(m.Id, today.AddDays(1).AddHours(18), 9.90m, "2D", true);
            AddProjectionIfMissing(m.Id, today.AddDays(2).AddHours(20), 10.90m, "2D", false);
        }

        context.SaveChanges();
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
                    throw new Exception(
                        $"Failed to create user {email}: {string.Join(", ", result.Errors.Select(e => e.Description))}");

                await userManager.AddToRoleAsync(user, role);
            }
        }
        // Desktop
        await CreateUserAsync("admin@icinema.com", "Admin@12345", "Admin");
        // Mobile
        await CreateUserAsync("staff@icinema.com", "Staff@12345", "Staff");
        await CreateUserAsync("customer@icinema.com", "Customer@12345", "Customer");
    }

    private static void SeedGenres(iCinemaDbContext context)
    {
        // Ensure a broader set of common genres exists; add missing by name (idempotent)
        var genreNames = new[]
        {
            "Action", "Comedy", "Drama", "Thriller", "Sci-Fi", "Fantasy",
            "Romance", "Crime", "Biography"
        };

        var toAdd = new List<Genre>();
        foreach (var name in genreNames)
        {
            if (!context.Genres.Any(g => g.Name == name))
            {
                toAdd.Add(new Genre { Id = Guid.NewGuid(), Name = name });
            }
        }

        if (toAdd.Count > 0)
        {
            context.Genres.AddRange(toAdd);
            context.SaveChanges();
        }
    }

    private static void SeedDirectors(iCinemaDbContext context)
    {
        if (context.Directors.Any()) return;

        var directors = new List<Director>
        {
            new Director
            {
                Id = SeedConstants.Directors.ChristopherNolan, FullName = "Christopher Nolan", Bio = null,
                PhotoUrl = null
            },
            new Director
            {
                Id = SeedConstants.Directors.DenisVilleneuve, FullName = "Denis Villeneuve", Bio = null, PhotoUrl = null
            },
            new Director
                { Id = SeedConstants.Directors.GretaGerwig, FullName = "Greta Gerwig", Bio = null, PhotoUrl = null },
            new Director
            {
                Id = SeedConstants.Directors.MartinScorsese, FullName = "Martin Scorsese", Bio = null, PhotoUrl = null
            }
        };

        context.Directors.AddRange(directors);
        context.SaveChanges();
    }

    private static void SeedActors(iCinemaDbContext context)
    {
        if (context.Actors.Any()) return;

        var actors = new List<Actor>
        {
            new Actor
            {
                Id = SeedConstants.Actors.LeonardoDiCaprio, FullName = "Leonardo DiCaprio", Bio = null, PhotoUrl = null
            },
            new Actor
            {
                Id = SeedConstants.Actors.CillianMurphy, FullName = "Cillian Murphy", Bio = null, PhotoUrl = null
            },
            new Actor { Id = SeedConstants.Actors.RyanGosling, FullName = "Ryan Gosling", Bio = null, PhotoUrl = null },
            new Actor { Id = SeedConstants.Actors.EmilyBlunt, FullName = "Emily Blunt", Bio = null, PhotoUrl = null },
            new Actor
            {
                Id = SeedConstants.Actors.MargotRobbie, FullName = "Margot Robbie", Bio = null, PhotoUrl = null
            },
            new Actor
            {
                Id = SeedConstants.Actors.RobertDeNiro, FullName = "Robert De Niro", Bio = null, PhotoUrl = null
            }
        };

        context.Actors.AddRange(actors);
        context.SaveChanges();
    }

    private static async Task SeedRoles(RoleManager<ApplicationRole> roleManager)
    {
        var roles = new[] { "Admin", "Customer", "Staff" };
        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
                await roleManager.CreateAsync(new ApplicationRole { Name = role, NormalizedName = role.ToUpper() });
        }
    }

    public static async Task SeedAsync(iCinemaDbContext context, UserManager<ApplicationUser> userManager,
        RoleManager<ApplicationRole> roleManager)
    {
        SeedCountries(context);
        SeedCities(context);
        SeedGenres(context);
        SeedDirectors(context);
        SeedActors(context);
        SeedMovies(context);
        SeedProjections(context);
        await SeedRoles(roleManager);
        await SeedUsers(context, userManager);
    }

    private static void SeedMovies(iCinemaDbContext context)
    {
        // Create a few demo movies only if they don't already exist (by Title)
        bool HasMovie(string title) => context.Movies.Any(m => m.Title == title);

        // Helper: get genre ids by name
        Guid? GenreId(string name) => context.Genres.Where(g => g.Name == name).Select(g => g.Id).FirstOrDefault();

        // Oppenheimer
        if (!HasMovie("Oppenheimer"))
        {
            var oppenheimer = new Movie
            {
                Id = Guid.NewGuid(),
                Title = "Oppenheimer",
                Description = "Biographical drama about J. Robert Oppenheimer.",
                DurationMin = 180,
                ReleaseDate = new DateOnly(2023, 7, 21),
                DirectorId = SeedConstants.Directors.ChristopherNolan,
                AgeRating = "R",
                Language = "English",
                TrailerUrl = null,
            };
            context.Movies.Add(oppenheimer);
            context.SaveChanges();

            var oppGenres = new[] { "Drama", "Biography", "Thriller" }
                .Select(GenreId).Where(id => id.HasValue).Select(id => id!.Value)
                .Select(gid => new MovieGenre { MovieId = oppenheimer.Id, GenreId = gid })
                .ToList();
            if (oppGenres.Count > 0)
            {
                context.MovieGenres.AddRange(oppGenres);
            }

            var oppCast = new List<MovieActor>
            {
                new MovieActor
                {
                    MovieId = oppenheimer.Id, ActorId = SeedConstants.Actors.CillianMurphy,
                    RoleName = "J. Robert Oppenheimer"
                },
                new MovieActor
                {
                    MovieId = oppenheimer.Id, ActorId = SeedConstants.Actors.EmilyBlunt, RoleName = "Kitty Oppenheimer"
                }
            };
            context.MovieActors.AddRange(oppCast);
            context.SaveChanges();
        }

        // Barbie
        if (!HasMovie("Barbie"))
        {
            var barbie = new Movie
            {
                Id = Guid.NewGuid(),
                Title = "Barbie",
                Description = "A comedic fantasy about Barbie and Ken.",
                DurationMin = 114,
                ReleaseDate = new DateOnly(2023, 7, 21),
                DirectorId = SeedConstants.Directors.GretaGerwig,
                AgeRating = "PG-13",
                Language = "English",
                TrailerUrl = null,
            };
            context.Movies.Add(barbie);
            context.SaveChanges();

            var barbieGenres = new[] { "Comedy", "Fantasy" }
                .Select(GenreId).Where(id => id.HasValue).Select(id => id!.Value)
                .Select(gid => new MovieGenre { MovieId = barbie.Id, GenreId = gid })
                .ToList();
            if (barbieGenres.Count > 0)
            {
                context.MovieGenres.AddRange(barbieGenres);
            }

            var barbieCast = new List<MovieActor>
            {
                new MovieActor
                    { MovieId = barbie.Id, ActorId = SeedConstants.Actors.MargotRobbie, RoleName = "Barbie" },
                new MovieActor { MovieId = barbie.Id, ActorId = SeedConstants.Actors.RyanGosling, RoleName = "Ken" }
            };
            context.MovieActors.AddRange(barbieCast);
            context.SaveChanges();
        }

        // Killers of the Flower Moon
        if (!HasMovie("Killers of the Flower Moon"))
        {
            var kotfm = new Movie
            {
                Id = Guid.NewGuid(),
                Title = "Killers of the Flower Moon",
                Description = "A crime drama about the murders within the Osage Nation.",
                DurationMin = 206,
                ReleaseDate = new DateOnly(2023, 10, 20),
                DirectorId = SeedConstants.Directors.MartinScorsese,
                AgeRating = "R",
                Language = "English",
                TrailerUrl = null,
            };
            context.Movies.Add(kotfm);
            context.SaveChanges();

            var kotfmGenres = new[] { "Crime", "Drama" }
                .Select(GenreId).Where(id => id.HasValue).Select(id => id!.Value)
                .Select(gid => new MovieGenre { MovieId = kotfm.Id, GenreId = gid })
                .ToList();
            if (kotfmGenres.Count > 0)
            {
                context.MovieGenres.AddRange(kotfmGenres);
            }

            var kotfmCast = new List<MovieActor>
            {
                new MovieActor
                {
                    MovieId = kotfm.Id, ActorId = SeedConstants.Actors.LeonardoDiCaprio, RoleName = "Ernest Burkhart"
                },
                new MovieActor
                    { MovieId = kotfm.Id, ActorId = SeedConstants.Actors.RobertDeNiro, RoleName = "William Hale" }
            };
            context.MovieActors.AddRange(kotfmCast);
            context.SaveChanges();
        }
    }
}