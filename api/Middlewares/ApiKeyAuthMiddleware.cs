using System;

namespace api.Middlewares;

public class ApiKeyAuthMiddleware
{
  private readonly RequestDelegate _next;
  private readonly IConfiguration _configuration;
  private const string ApiKeyHeader = "X-Api-Key";

  public ApiKeyAuthMiddleware(RequestDelegate next, IConfiguration configuration)
  {
    _next = next;
    _configuration = configuration;
  }

  public async Task InvokeAsync(HttpContext context)
  {
    var path = context.Request.Path.Value?.ToLower();

    // if (context.Request.Path.StartsWithSegments("/health"))
    // {
    //     await _next(context);
    //     return;
    // }
    if (path != null && (
          path.StartsWith("/health") ||
          path.StartsWith("/swagger") ||
          path.StartsWith("/openapi") ||
          path.StartsWith("/scalar")
        ))
    {
      await _next(context);
      return;
    }


    if (!context.Request.Headers.TryGetValue(ApiKeyHeader, out var extractedApiKey))
    {
      context.Response.StatusCode = 401;
      await context.Response.WriteAsync("Api Key missing.");
      return;
    }

    var apiKey = Environment.GetEnvironmentVariable("API_KEY");

    // Tratar espaços e quebras de linha
    var apiKeyTrimmed = apiKey?.Trim();
    var extractedApiKeyTrimmed = extractedApiKey.ToString().Trim();

    if (string.IsNullOrEmpty(apiKeyTrimmed) || !apiKeyTrimmed.Equals(extractedApiKeyTrimmed))
    {
      context.Response.StatusCode = 401;
      await context.Response.WriteAsync($"Invalid API Key.\nAPI_KEY: {apiKeyTrimmed}, Extracted API Key: {extractedApiKeyTrimmed}");
      return;
    }

    await _next(context);
  }
}