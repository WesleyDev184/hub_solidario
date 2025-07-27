using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app
{
    /// <inheritdoc />
    public partial class appv8 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Stocks_OrthopedicBanks_OrthopedicBankId",
                table: "Stocks");

            migrationBuilder.DropTable(
                name: "OrthopedicBanks");

            migrationBuilder.RenameColumn(
                name: "OrthopedicBankId",
                table: "Stocks",
                newName: "HubId");

            migrationBuilder.RenameIndex(
                name: "IX_Stocks_OrthopedicBankId",
                table: "Stocks",
                newName: "IX_Stocks_HubId");

            migrationBuilder.CreateTable(
                name: "Hubs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    City = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Hubs", x => x.Id);
                });

            migrationBuilder.AddForeignKey(
                name: "FK_Stocks_Hubs_HubId",
                table: "Stocks",
                column: "HubId",
                principalTable: "Hubs",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Stocks_Hubs_HubId",
                table: "Stocks");

            migrationBuilder.DropTable(
                name: "Hubs");

            migrationBuilder.RenameColumn(
                name: "HubId",
                table: "Stocks",
                newName: "OrthopedicBankId");

            migrationBuilder.RenameIndex(
                name: "IX_Stocks_HubId",
                table: "Stocks",
                newName: "IX_Stocks_OrthopedicBankId");

            migrationBuilder.CreateTable(
                name: "OrthopedicBanks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    City = table.Column<string>(type: "text", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Name = table.Column<string>(type: "text", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrthopedicBanks", x => x.Id);
                });

            migrationBuilder.AddForeignKey(
                name: "FK_Stocks_OrthopedicBanks_OrthopedicBankId",
                table: "Stocks",
                column: "OrthopedicBankId",
                principalTable: "OrthopedicBanks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
