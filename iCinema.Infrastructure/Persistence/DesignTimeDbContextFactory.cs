using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace iCinema.Infrastructure.Persistence;

public class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<iCinemaDbContext>
{
    public iCinemaDbContext CreateDbContext(string[] args)
    {
        // Navigate to ../iCinema.Api/appsettings.json relative to Infrastructure
        var basePath = Path.Combine(Directory.GetCurrentDirectory(), "../iCinema.Api");

        IConfigurationRoot configuration = new ConfigurationBuilder()
            .SetBasePath(basePath)
            .AddJsonFile("appsettings.json")
            .Build();

        var connectionString = configuration.GetConnectionString("DefaultConnection");

        var optionsBuilder = new DbContextOptionsBuilder<iCinemaDbContext>();
        optionsBuilder.UseSqlServer(connectionString);

        return new iCinemaDbContext(optionsBuilder.Options);
    }
}