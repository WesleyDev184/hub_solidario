using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.ComponentModel;
using System.Reflection;
using System.ComponentModel.DataAnnotations;

namespace api.Swagger;

public class EnumSchemaFilter : ISchemaFilter
{
  public void Apply(OpenApiSchema schema, SchemaFilterContext context)
  {
    if (context.Type.IsEnum)
    {
      schema.Enum.Clear(); // Limpa as definições de enum padrão (apenas números)

      // Obtém os nomes dos membros do enum
      foreach (var name in Enum.GetNames(context.Type))
      {
        var memberInfo = context.Type.GetMember(name).FirstOrDefault();
        var descriptionAttribute = memberInfo?.GetCustomAttribute<DescriptionAttribute>();
        var displayAttribute = memberInfo?.GetCustomAttribute<DisplayAttribute>();

        string? description = displayAttribute?.Description ?? descriptionAttribute?.Description;

        if (!string.IsNullOrEmpty(description))
        {
          // Se houver uma descrição, adicione o valor e a descrição
          schema.Enum.Add(new OpenApiString($"{name} ({description})"));
        }
        else
        {
          // Caso contrário, adicione apenas o nome
          schema.Enum.Add(new OpenApiString(name));
        }
      }

      // Opcional: Adicionar a descrição do enum como um todo
      var enumDescriptionAttribute = context.Type.GetCustomAttribute<DescriptionAttribute>();
      if (enumDescriptionAttribute != null && !string.IsNullOrEmpty(enumDescriptionAttribute.Description))
      {
        schema.Description = enumDescriptionAttribute.Description;
      }
    }
  }
}
