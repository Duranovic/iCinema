using System.Net;
using System.Text.Json;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Api.Middleware;

public class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (DbUpdateException ex)
        {
            // Safety net for FK violations or other DB update issues
            await HandleExceptionAsync(
                context,
                HttpStatusCode.BadRequest,
                "Greška pri brisanju",
                "Zapis je u upotrebi i ne može biti obrisan.");
        }
        catch (ValidationException ex)
        {
            logger.LogWarning("Validation error: {Message}", ex.Message);
            await HandleExceptionAsync(context, HttpStatusCode.BadRequest, "Greška validacije", ex.Message, ex.Errors);
        }
        catch (BusinessRuleException ex)
        {
            logger.LogWarning("Business rule violation: {Message}", ex.Message);
            await HandleExceptionAsync(context, HttpStatusCode.BadRequest, "Povreda poslovnih pravila", ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception occurred.");
            await HandleExceptionAsync(context, HttpStatusCode.InternalServerError, "Interna greška servera", "Dogodila se neočekivana greška.");
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, HttpStatusCode statusCode, string error, string message, IDictionary<string, string[]>? details = null)
    {
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        var apiError = new ApiError
        {
            Status = (int)statusCode,
            Error = error,
            Message = message,
            TraceId = context.TraceIdentifier,
            Details = details
        };

        var json = JsonSerializer.Serialize(apiError, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        return context.Response.WriteAsync(json);
    }
}