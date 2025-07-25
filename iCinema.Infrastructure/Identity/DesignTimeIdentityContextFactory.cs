using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace iCinema.Infrastructure.Identity;

public class DesignTimeIdentityContextFactory : IDesignTimeDbContextFactory<iCinemaIdentityContext>
{
    public iCinemaIdentityContext CreateDbContext(string[] args)
    {
        var basePath = Path.Combine(Directory.GetCurrentDirectory(), "../iCinema.Api");
        
        var configuration = new ConfigurationBuilder()
            .SetBasePath(basePath)
            .AddJsonFile("appsettings.json", optional: false)
            .Build();

        var connectionString = configuration.GetConnectionString("DefaultConnection");
        var optionsBuilder = new DbContextOptionsBuilder<iCinemaIdentityContext>();
        optionsBuilder.UseSqlServer(connectionString);

        return new iCinemaIdentityContext(optionsBuilder.Options);
    }
}