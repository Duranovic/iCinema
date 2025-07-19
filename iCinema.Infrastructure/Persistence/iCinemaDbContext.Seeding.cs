using iCinema.Infrastructure.Persistence.Configurations;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence;

public partial class iCinemaDbContext
{
    partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
    {
        DatabaseSeed.Seed(modelBuilder);
    }
}