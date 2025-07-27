using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Stocks.Dto.ExampleDoc
{
  /// <summary>
  /// Exemplo de requisição para criar um stock (usado para JSON requests)
  /// </summary>
  public class ExampleRequestCreateStockDto : IExamplesProvider<RequestCreateStockDto>
  {
    public RequestCreateStockDto GetExamples()
    {
      return new RequestCreateStockDto(
        Title: "Cadeira de Rodas Dobrável",
        ImageFile: null, // Para JSON requests, o arquivo não é enviado diretamente
        HubId: new Guid("12345678-1234-1234-1234-123456789012") // ID de exemplo fixo
      );
    }
  }

  /// <summary>
  /// Exemplo de requisição para criar um stock via form-data (usado para multipart/form-data requests)
  /// Este exemplo mostra como enviar dados via form-data incluindo upload de arquivo
  /// </summary>
  public class ExampleRequestCreateStockFormDto : IExamplesProvider<RequestCreateStockDto>
  {
    public RequestCreateStockDto GetExamples()
    {
      return new RequestCreateStockDto(
        Title: "Cadeira de Rodas Dobrável",
        ImageFile: null, // O arquivo será enviado via form-data no campo "ImageFile"
        HubId: new Guid("12345678-1234-1234-1234-123456789012") // ID de exemplo fixo
      );
    }
  }

  /// <summary>
  /// Exemplo de requisição para atualizar um stock existente
  /// </summary>
  public class ExampleRequestUpdateStockDto : IExamplesProvider<RequestUpdateStockDto>
  {
    public RequestUpdateStockDto GetExamples()
    {
      return new RequestUpdateStockDto(
        Title: "Cadeira de Rodas Dobrável - Atualizada",
        ImageFile: null, // O arquivo será enviado via form-data no campo "ImageFile"
        MaintenanceQtd: 2,  // Quantidade em manutenção
        AvailableQtd: 8,    // Quantidade disponível
        BorrowedQtd: 5      // Quantidade emprestada
      );
    }
  }

  /// <summary>
  /// Exemplo de requisição para atualizar um stock via form-data (usado para multipart/form-data requests)
  /// Este exemplo mostra como enviar dados via form-data incluindo upload de arquivo
  /// </summary>
  public class ExampleRequestUpdateStockFormDto : IExamplesProvider<RequestUpdateStockDto>
  {
    public RequestUpdateStockDto GetExamples()
    {
      return new RequestUpdateStockDto(
        Title: "Cadeira de Rodas Dobrável - Atualizada",
        ImageFile: null, // O arquivo será enviado via form-data no campo "ImageFile"
        MaintenanceQtd: 2,  // Quantidade em manutenção
        AvailableQtd: 8,    // Quantidade disponível
        BorrowedQtd: 5      // Quantidade emprestada
      );
    }
  }
}