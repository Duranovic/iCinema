using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class MovieConfiguration : IEntityTypeConfiguration<Movie>
{
    public void Configure(EntityTypeBuilder<Movie> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Movies__3214EC07269DD239");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.AgeRating).HasMaxLength(10);
        builder.Property(e => e.Language).HasMaxLength(50);
        builder.Property(e => e.PosterUrl).HasMaxLength(250);
        builder.Property(e => e.Title).HasMaxLength(200);
        builder.Property(e => e.TrailerUrl).HasMaxLength(250);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        builder.HasOne(d => d.Director)
            .WithMany(p => p.Movies)
            .HasForeignKey(d => d.DirectorId)
            .HasConstraintName("FK_Movies_Director");
    }
}

