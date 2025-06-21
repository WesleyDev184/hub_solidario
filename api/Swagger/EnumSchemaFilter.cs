using Microsoft.OpenApi.Any;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;
using System.ComponentModel;
using System.Reflection;
using System.ComponentModel.DataAnnotations;

namespace api.Swagger
{
  public class EnumSchemaFilter : ISchemaFilter
  {
    public void Apply(OpenApiSchema schema, SchemaFilterContext context)
    {
      if (!context.Type.IsEnum)
      {
        return;
      }

      schema.Enum.Clear(); // Limpa as definições de enum padrão (apenas números)

      // Obtém os nomes dos membros do enum
      foreach (string name in Enum.GetNames(context.Type))
      {
        MemberInfo? memberInfo = context.Type.GetMember(name).FirstOrDefault();
        DescriptionAttribute? descriptionAttribute = memberInfo?.GetCustomAttribute<DescriptionAttribute>();
        DisplayAttribute? displayAttribute = memberInfo?.GetCustomAttribute<DisplayAttribute>();

        string? description = displayAttribute?.Description ?? descriptionAttribute?.Description;

        // Se houver uma descrição, adicione o valor e a descrição
        schema.Enum.Add(!string.IsNullOrEmpty(description)
          ? new OpenApiString($"{name} ({description})")
          // Caso contrário, adicione apenas o nome
          : new OpenApiString(name));
      }

      // Opcional: Adicionar a descrição do enum como um todo
      DescriptionAttribute? enumDescriptionAttribute = context.Type.GetCustomAttribute<DescriptionAttribute>();
      if (enumDescriptionAttribute != null && !string.IsNullOrEmpty(enumDescriptionAttribute.Description))
      {
        schema.Description = enumDescriptionAttribute.Description;
      }
    }
  }
}