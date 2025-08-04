using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.auth
{
    /// <inheritdoc />
    public partial class authv3 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "DeviceToken",
                schema: "auth",
                table: "AspNetUsers",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DeviceToken",
                schema: "auth",
                table: "AspNetUsers");
        }
    }
}
