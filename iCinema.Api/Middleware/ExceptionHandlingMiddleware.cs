using System.Net;
using System.Text.Json;
using iCinema.Application.Common.Constants;
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
            logger.LogWarning(ex, 
                "Database update error occurred. TraceId: {TraceId}, Path: {Path}", 
                context.TraceIdentifier, 
                context.Request.Path);
            await HandleExceptionAsync(
                context,
                HttpStatusCode.BadRequest,
                ErrorMessages.DeleteError,
                ErrorMessages.DeleteInUse);
        }
        catch (ValidationException ex)
        {
            logger.LogWarning(
                "Validation error. TraceId: {TraceId}, Path: {Path}, Errors: {ErrorCount}", 
                context.TraceIdentifier, 
                context.Request.Path,
                ex.Errors?.Count ?? 0);
            await HandleExceptionAsync(context, HttpStatusCode.BadRequest, ErrorMessages.ValidationError, ex.Message, ex.Errors);
        }
        catch (BusinessRuleException ex)
        {
            logger.LogWarning(
                "Business rule violation. TraceId: {TraceId}, Path: {Path}, Message: {Message}", 
                context.TraceIdentifier, 
                context.Request.Path,
                ex.Message);
            await HandleExceptionAsync(context, HttpStatusCode.BadRequest, ErrorMessages.BusinessRuleViolation, ex.Message);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, 
                "Unhandled exception occurred. TraceId: {TraceId}, Path: {Path}, Method: {Method}", 
                context.TraceIdentifier, 
                context.Request.Path,
                context.Request.Method);
            await HandleExceptionAsync(context, HttpStatusCode.InternalServerError, ErrorMessages.InternalServerError, ErrorMessages.UnexpectedError);
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