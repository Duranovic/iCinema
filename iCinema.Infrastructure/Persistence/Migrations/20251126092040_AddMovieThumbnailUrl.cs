using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace iCinema.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddMovieThumbnailUrl : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ThumbnailUrl",
                table: "Movies",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ThumbnailUrl",
                table: "Movies");
        }
    }
}
