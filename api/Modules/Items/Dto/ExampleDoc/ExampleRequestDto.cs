using System;
using api.Modules.Items.Dto;
using api.Modules.Items.Enum;
using Swashbuckle.AspNetCore.Filters;

namespace api.Modules.Items.Dto.ExampleDoc
{
    public class ExampleRequestCreateItemDto : IExamplesProvider<RequestCreateItemDto>
    {
        public RequestCreateItemDto GetExamples()
        {
            return new RequestCreateItemDto(
                SeriaCode: 12345,
                StockId: Guid.Parse("aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"),
                ImageUrl: "https://example.com/item-image.png",
                Status: ItemStatus.AVAILABLE  // Exemplo: ajuste conforme os valores definidos no seu enum
            );
        }
    }

    public class ExampleRequestUpdateItemDto : IExamplesProvider<RequestUpdateItemDto>
    {
        public RequestUpdateItemDto GetExamples()
        {
            return new RequestUpdateItemDto(
                SeriaCode: 54321,
                ImageUrl: "https://example.com/new-item-image.png",
                Status: ItemStatus.UNAVAILABLE  // Exemplo: ajuste conforme os valores definidos no seu enum
            );
        }
    }
}