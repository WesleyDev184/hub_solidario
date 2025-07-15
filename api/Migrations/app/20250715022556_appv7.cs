using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app
{
    /// <inheritdoc />
    public partial class appv7 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Applicants_ApplicantId",
                table: "Loans");

            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Items_ItemId",
                table: "Loans");

            migrationBuilder.AddForeignKey(
                name: "FK_Loans_Applicants_ApplicantId",
                table: "Loans",
                column: "ApplicantId",
                principalTable: "Applicants",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Loans_Items_ItemId",
                table: "Loans",
                column: "ItemId",
                principalTable: "Items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Applicants_ApplicantId",
                table: "Loans");

            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Items_ItemId",
                table: "Loans");

            migrationBuilder.AddForeignKey(
                name: "FK_Loans_Applicants_ApplicantId",
                table: "Loans",
                column: "ApplicantId",
                principalTable: "Applicants",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Loans_Items_ItemId",
                table: "Loans",
                column: "ItemId",
                principalTable: "Items",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
