using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app
{
  /// <inheritdoc />
  public partial class appv9 : Migration
  {
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.AddColumn<Guid>(
          name: "HubId",
          table: "Applicants",
          type: "uuid",
          nullable: false,
          defaultValue: new Guid("76571466-e6f1-4f55-832b-6c29392d6de1"));

      migrationBuilder.CreateIndex(
          name: "IX_Applicants_HubId",
          table: "Applicants",
          column: "HubId");

      migrationBuilder.AddForeignKey(
          name: "FK_Applicants_Hubs_HubId",
          table: "Applicants",
          column: "HubId",
          principalTable: "Hubs",
          principalColumn: "Id",
          onDelete: ReferentialAction.Restrict);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.DropForeignKey(
          name: "FK_Applicants_Hubs_HubId",
          table: "Applicants");

      migrationBuilder.DropIndex(
          name: "IX_Applicants_HubId",
          table: "Applicants");

      migrationBuilder.DropColumn(
          name: "HubId",
          table: "Applicants");
    }
  }
}
