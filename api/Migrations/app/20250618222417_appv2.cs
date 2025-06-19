using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app {
    /// <inheritdoc />
    public partial class appv2 : Migration {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder) {
            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Applicants_ApplicantId",
                table: "Loans");

            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Items_ItemId",
                table: "Loans");

            migrationBuilder.CreateIndex(
                name: "IX_Stocks_Title",
                table: "Stocks",
                column: "Title");

            migrationBuilder.CreateIndex(
                name: "IX_Applicants_CPF",
                table: "Applicants",
                column: "CPF",
                unique: true);

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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder) {
            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Applicants_ApplicantId",
                table: "Loans");

            migrationBuilder.DropForeignKey(
                name: "FK_Loans_Items_ItemId",
                table: "Loans");

            migrationBuilder.DropIndex(
                name: "IX_Stocks_Title",
                table: "Stocks");

            migrationBuilder.DropIndex(
                name: "IX_Applicants_CPF",
                table: "Applicants");

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
    }
}
