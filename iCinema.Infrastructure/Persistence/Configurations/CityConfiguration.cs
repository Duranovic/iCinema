using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class CityConfiguration : IEntityTypeConfiguration<City>
{
    public void Configure(EntityTypeBuilder<City> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Cities__3214EC07B6373934");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.Name).HasMaxLength(100);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        builder.HasOne(d => d.Country)
            .WithMany(p => p.Cities)
            .HasForeignKey(d => d.CountryId)
            .OnDelete(DeleteBehavior.ClientSetNull)
            .HasConstraintName("FK_Cities_Countries");
    }
}

