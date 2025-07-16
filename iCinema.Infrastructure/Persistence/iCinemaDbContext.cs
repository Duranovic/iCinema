using System;
using System.Collections.Generic;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Models;

public partial class iCinemaDbContext : DbContext
{
    public iCinemaDbContext(DbContextOptions<iCinemaDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Cinema> Cinemas { get; set; }

    public virtual DbSet<City> Cities { get; set; }

    public virtual DbSet<Country> Countries { get; set; }

    public virtual DbSet<Genre> Genres { get; set; }

    public virtual DbSet<Hall> Halls { get; set; }

    public virtual DbSet<Movie> Movies { get; set; }

    public virtual DbSet<Projection> Projections { get; set; }

    public virtual DbSet<PromoCode> PromoCodes { get; set; }

    public virtual DbSet<Rating> Ratings { get; set; }

    public virtual DbSet<Recommendation> Recommendations { get; set; }

    public virtual DbSet<Reservation> Reservations { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Seat> Seats { get; set; }

    public virtual DbSet<Ticket> Tickets { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Cinema>(entity =>
        {
            entity.HasKey(e => e.CinemaID).HasName("PK__Cinemas__59C92626CF2C284C");

            entity.Property(e => e.Address).HasMaxLength(250);
            entity.Property(e => e.Name).HasMaxLength(150);

            entity.HasOne(d => d.City).WithMany(p => p.Cinemas)
                .HasForeignKey(d => d.CityID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Cinemas_Cities");
        });

        modelBuilder.Entity<City>(entity =>
        {
            entity.HasKey(e => e.CityID).HasName("PK__Cities__F2D21A964A571622");

            entity.Property(e => e.Name).HasMaxLength(100);

            entity.HasOne(d => d.Country).WithMany(p => p.Cities)
                .HasForeignKey(d => d.CountryID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Cities_Countries");
        });

        modelBuilder.Entity<Country>(entity =>
        {
            entity.HasKey(e => e.CountryID).HasName("PK__Countrie__10D160BF2B2EAAC4");

            entity.Property(e => e.Name).HasMaxLength(100);
        });

        modelBuilder.Entity<Genre>(entity =>
        {
            entity.HasKey(e => e.GenreID).HasName("PK__Genres__0385055E9D12FF1E");

            entity.Property(e => e.Name).HasMaxLength(50);
        });

        modelBuilder.Entity<Hall>(entity =>
        {
            entity.HasKey(e => e.HallID).HasName("PK__Halls__7E60E2743B8B3599");

            entity.Property(e => e.Name).HasMaxLength(50);

            entity.HasOne(d => d.Cinema).WithMany(p => p.Halls)
                .HasForeignKey(d => d.CinemaID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Halls_Cinemas");
        });

        modelBuilder.Entity<Movie>(entity =>
        {
            entity.HasKey(e => e.MovieID).HasName("PK__Movies__4BD2943AECB9F1DF");

            entity.Property(e => e.PosterUrl).HasMaxLength(250);
            entity.Property(e => e.Title).HasMaxLength(200);

            entity.HasOne(d => d.Genre).WithMany(p => p.Movies)
                .HasForeignKey(d => d.GenreID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Movies_Genres");
        });

        modelBuilder.Entity<Projection>(entity =>
        {
            entity.HasKey(e => e.ProjectionID).HasName("PK__Projecti__B60582F97F3D4E4E");

            entity.HasIndex(e => e.StartTime, "IX_Projections_StartTime");

            entity.Property(e => e.Price).HasColumnType("decimal(8, 2)");
            entity.Property(e => e.StartTime).HasColumnType("datetime");

            entity.HasOne(d => d.Hall).WithMany(p => p.Projections)
                .HasForeignKey(d => d.HallID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Projections_Halls");

            entity.HasOne(d => d.Movie).WithMany(p => p.Projections)
                .HasForeignKey(d => d.MovieID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Projections_Movies");
        });

        modelBuilder.Entity<PromoCode>(entity =>
        {
            entity.HasKey(e => e.PromoCodeID).HasName("PK__PromoCod__867BC5667C918B7E");

            entity.HasIndex(e => e.Code, "UQ__PromoCod__A25C5AA7B26E8443").IsUnique();

            entity.Property(e => e.Code).HasMaxLength(50);
            entity.Property(e => e.DiscountPercent).HasColumnType("decimal(5, 2)");
            entity.Property(e => e.IsActive).HasDefaultValue(true);
            entity.Property(e => e.ValidFrom).HasColumnType("datetime");
            entity.Property(e => e.ValidTo).HasColumnType("datetime");
        });

        modelBuilder.Entity<Rating>(entity =>
        {
            entity.HasKey(e => e.RatingID).HasName("PK__Ratings__FCCDF85C6144DDF8");

            entity.HasIndex(e => new { e.UserID, e.MovieID }, "UQ_Ratings_User_Movie").IsUnique();

            entity.Property(e => e.RatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Movie).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.MovieID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ratings_Movies");

            entity.HasOne(d => d.User).WithMany(p => p.Ratings)
                .HasForeignKey(d => d.UserID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Ratings_Users");
        });

        modelBuilder.Entity<Recommendation>(entity =>
        {
            entity.HasKey(e => e.RecommendationID).HasName("PK__Recommen__AA15BEC4A53E9365");

            entity.HasOne(d => d.Movie).WithMany(p => p.Recommendations)
                .HasForeignKey(d => d.MovieID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Recommendations_Movies");

            entity.HasOne(d => d.User).WithMany(p => p.Recommendations)
                .HasForeignKey(d => d.UserID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Recommendations_Users");
        });

        modelBuilder.Entity<Reservation>(entity =>
        {
            entity.HasKey(e => e.ReservationID).HasName("PK__Reservat__B7EE5F04F47E6E19");

            entity.HasIndex(e => e.UserID, "IX_Reservations_UserID");

            entity.Property(e => e.ReservedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");

            entity.HasOne(d => d.Projection).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.ProjectionID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservations_Projections");

            entity.HasOne(d => d.User).WithMany(p => p.Reservations)
                .HasForeignKey(d => d.UserID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Reservations_Users");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.HasKey(e => e.RoleID).HasName("PK__Roles__8AFACE3AB4125E46");

            entity.Property(e => e.Name).HasMaxLength(50);
        });

        modelBuilder.Entity<Seat>(entity =>
        {
            entity.HasKey(e => e.SeatID).HasName("PK__Seats__311713D3D90B3069");

            entity.HasIndex(e => new { e.HallID, e.RowNumber, e.SeatNumber }, "UQ_Seats_Hall_Row_Seat").IsUnique();

            entity.HasOne(d => d.Hall).WithMany(p => p.Seats)
                .HasForeignKey(d => d.HallID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Seats_Halls");
        });

        modelBuilder.Entity<Ticket>(entity =>
        {
            entity.HasKey(e => e.TicketID).HasName("PK__Tickets__712CC6272F3FB633");

            entity.HasIndex(e => e.QRCode, "IX_Tickets_QRCode");

            entity.HasIndex(e => new { e.ReservationID, e.SeatID }, "UQ_Tickets_Res_Seat").IsUnique();

            entity.Property(e => e.QRCode).HasMaxLength(200);
            entity.Property(e => e.TicketStatus)
                .HasMaxLength(20)
                .HasDefaultValue("Active");

            entity.HasOne(d => d.Reservation).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.ReservationID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Tickets_Reservations");

            entity.HasOne(d => d.Seat).WithMany(p => p.Tickets)
                .HasForeignKey(d => d.SeatID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Tickets_Seats");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.UserID).HasName("PK__Users__1788CCACDAAA1A92");

            entity.HasIndex(e => e.Username, "UQ__Users__536C85E4309E3B10").IsUnique();

            entity.HasIndex(e => e.Email, "UQ__Users__A9D105346501AD87").IsUnique();

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.Email).HasMaxLength(100);
            entity.Property(e => e.PasswordHash).HasMaxLength(200);
            entity.Property(e => e.Username).HasMaxLength(50);

            entity.HasOne(d => d.Role).WithMany(p => p.Users)
                .HasForeignKey(d => d.RoleID)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Users_Roles");
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
