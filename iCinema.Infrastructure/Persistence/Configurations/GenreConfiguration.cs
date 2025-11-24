using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class GenreConfiguration : IEntityTypeConfiguration<Genre>
{
    public void Configure(EntityTypeBuilder<Genre> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Genres__3214EC07DEAD6A98");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.Name).HasMaxLength(50);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");
    }
}

