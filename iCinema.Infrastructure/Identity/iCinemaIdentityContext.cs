using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Identity;

public class iCinemaIdentityContext(DbContextOptions<iCinemaIdentityContext> options)
    : IdentityDbContext<ApplicationUser, ApplicationRole, Guid>(options);