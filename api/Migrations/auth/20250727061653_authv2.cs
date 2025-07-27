using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.auth
{
    /// <inheritdoc />
    public partial class authv2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "OrthopedicBankId",
                schema: "auth",
                table: "AspNetUsers",
                newName: "HubId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "HubId",
                schema: "auth",
                table: "AspNetUsers",
                newName: "OrthopedicBankId");
        }
    }
}
