using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class DirectorConfiguration : IEntityTypeConfiguration<Director>
{
    public void Configure(EntityTypeBuilder<Director> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Director__3214EC0717AA3D8B");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.FullName).HasMaxLength(100);
        builder.Property(e => e.PhotoUrl).HasMaxLength(250);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");
    }
}

