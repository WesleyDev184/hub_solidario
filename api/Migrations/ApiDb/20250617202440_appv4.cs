using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.ApiDb
{
    /// <inheritdoc />
    public partial class appv4 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "StockId",
                table: "Items",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("fe39c5e0-70f0-4ddc-b19c-00acdad24e0a"));

            migrationBuilder.CreateIndex(
                name: "IX_Items_StockId",
                table: "Items",
                column: "StockId");

            migrationBuilder.AddForeignKey(
                name: "FK_Items_Stocks_StockId",
                table: "Items",
                column: "StockId",
                principalTable: "Stocks",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Items_Stocks_StockId",
                table: "Items");

            migrationBuilder.DropIndex(
                name: "IX_Items_StockId",
                table: "Items");

            migrationBuilder.DropColumn(
                name: "StockId",
                table: "Items");
        }
    }
}
