using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace iCinema.Infrastructure.Persistence.Configurations;

public class HallConfiguration : IEntityTypeConfiguration<Hall>
{
    public void Configure(EntityTypeBuilder<Hall> builder)
    {
        builder.HasKey(e => e.Id).HasName("PK__Halls__3214EC073E00AFC8");

        builder.Property(e => e.Id).HasDefaultValueSql("(newid())");
        builder.Property(e => e.HallType).HasMaxLength(50);
        builder.Property(e => e.IsDolbyAtmos).HasDefaultValue(false);
        builder.Property(e => e.Name).HasMaxLength(50);
        builder.Property(e => e.ScreenSize).HasMaxLength(50);
        builder.Property(e => e.CreatedAt).HasColumnType("datetime2");
        builder.Property(e => e.UpdatedAt).HasColumnType("datetime2");

        builder.HasOne(d => d.Cinema)
            .WithMany(p => p.Halls)
            .HasForeignKey(d => d.CinemaId)
            .OnDelete(DeleteBehavior.ClientSetNull)
            .HasConstraintName("FK_Halls_Cinemas");
    }
}

