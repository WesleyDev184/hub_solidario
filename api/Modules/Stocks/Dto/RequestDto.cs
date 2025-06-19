namespace api.Modules.Stocks.Dto;

//Create Stock
public record RequestCreateStockDto(string Title);

public record RequestUpdateStockDto(string? Title, int? MaintenanceQtd, int? AvailableQtd, int? BorrowedQtd);
