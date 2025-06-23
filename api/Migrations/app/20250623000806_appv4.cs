using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app
{
  /// <inheritdoc />
  public partial class appv4 : Migration
  {
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.AddColumn<Guid>(
        name: "OrthopedicBankId",
        table: "Stocks",
        type: "uuid",
        nullable: false,
        defaultValue: new Guid("7472645b-c83d-478c-b745-ebf0641d7359"));

      migrationBuilder.CreateIndex(
        name: "IX_Stocks_OrthopedicBankId",
        table: "Stocks",
        column: "OrthopedicBankId");

      migrationBuilder.AddForeignKey(
        name: "FK_Stocks_OrthopedicBanks_OrthopedicBankId",
        table: "Stocks",
        column: "OrthopedicBankId",
        principalTable: "OrthopedicBanks",
        principalColumn: "Id",
        onDelete: ReferentialAction.Cascade);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.DropForeignKey(
        name: "FK_Stocks_OrthopedicBanks_OrthopedicBankId",
        table: "Stocks");

      migrationBuilder.DropIndex(
        name: "IX_Stocks_OrthopedicBankId",
        table: "Stocks");

      migrationBuilder.DropColumn(
        name: "OrthopedicBankId",
        table: "Stocks");
    }
  }
}