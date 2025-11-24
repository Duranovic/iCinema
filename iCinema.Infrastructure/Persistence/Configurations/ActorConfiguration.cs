using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class ActorConfiguration : IEntityTypeConfiguration<Actor>
{
    public void Configure(EntityTypeBuilder<Actor> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Actors__3214EC07DC3757D0");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.FullName).HasMaxLength(100);
        builder.Property(e => e.PhotoUrl).HasMaxLength(250);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");
    }
}

