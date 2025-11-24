using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class ProjectionConfiguration : IEntityTypeConfiguration<Projection>
{
    public void Configure(EntityTypeBuilder<Projection> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Projecti__3214EC07DD1D3F4C");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.IsActive).HasDefaultValue(true);
        builder.Property(e => e.IsSubtitled).HasDefaultValue(false);
        builder.Property(e => e.Price).HasColumnType("decimal(8, 2)");
        builder.Property(e => e.ProjectionType).HasMaxLength(20);
        builder.Property(e => e.StartTime).HasColumnType("datetime");
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        builder.HasOne(d => d.Hall)
            .WithMany(p => p.Projections)
            .HasForeignKey(d => d.HallId)
            .OnDelete(DeleteBehavior.ClientSetNull)
            .HasConstraintName("FK_Projections_Halls");

        builder.HasOne(d => d.Movie)
            .WithMany(p => p.Projections)
            .HasForeignKey(d => d.MovieId)
            .OnDelete(DeleteBehavior.ClientSetNull)
            .HasConstraintName("FK_Projections_Movies");
    }
}

