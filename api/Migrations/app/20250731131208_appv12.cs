using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app
{
    /// <inheritdoc />
    public partial class appv12 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "DependentId",
                table: "Loans",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Loans_DependentId",
                table: "Loans",
                column: "DependentId");

            migrationBuilder.AddForeignKey(
                name: "FK_Loans_Dependents_DependentId",
                table: "Loans",
                column: "DependentId",
                principalTable: "Dependents",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Dependents_DependentId",
                table: "Loans");

            migrationBuilder.DropIndex(
                name: "IX_Loans_DependentId",
                table: "Loans");

            migrationBuilder.DropColumn(
                name: "DependentId",
                table: "Loans");
        }
    }
}
