using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace iCinema.Infrastructure.Persistence;

public class DesignTimeIdentityContextFactory : IDesignTimeDbContextFactory<iCinemaDbContext>
{
    public iCinemaDbContext CreateDbContext(string[] args)
    {
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