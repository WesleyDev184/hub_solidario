using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace api.Migrations.app
{
  /// <inheritdoc />
  public partial class appv5 : Migration
  {
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.AddColumn<string>(
          name: "ImageUrl",
          table: "Stocks",
          type: "text",
          nullable: false,
          defaultValue: "https://pt.vecteezy.com/png-gratis/cadeira-de-rodas");
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.DropColumn(
          name: "ImageUrl",
          table: "Stocks");
    }
  }
}
