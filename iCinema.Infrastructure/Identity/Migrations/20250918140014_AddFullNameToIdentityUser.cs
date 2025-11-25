using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace iCinema.Infrastructure.Identity.Migrations
{
    /// <inheritdoc />
    public partial class AddFullNameToIdentityUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Only add column if table exists and column doesn't exist
            migrationBuilder.Sql(@"
                IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'AspNetUsers')
                    AND NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('AspNetUsers') AND name = 'FullName')
                BEGIN
                    ALTER TABLE [AspNetUsers] ADD [FullName] nvarchar(max) NULL;
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FullName",
                table: "AspNetUsers");
        }
    }
}
