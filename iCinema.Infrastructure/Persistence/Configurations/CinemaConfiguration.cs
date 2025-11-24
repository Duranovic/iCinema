using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class CinemaConfiguration : IEntityTypeConfiguration<Cinema>
{
    public void Configure(EntityTypeBuilder<Cinema> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Cinemas__3214EC07336722AE");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.Address).HasMaxLength(250);
        builder.Property(e => e.Name).HasMaxLength(150);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        builder.HasOne(d => d.City)
            .WithMany(p => p.Cinemas)
            .HasForeignKey(d => d.CityId)
            .OnDelete(DeleteBehavior.ClientSetNull)
            .HasConstraintName("FK_Cinemas_Cities");
    }
}

