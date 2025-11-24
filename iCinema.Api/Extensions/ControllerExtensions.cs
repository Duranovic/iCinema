using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Models;
using Microsoft.AspNetCore.Mvc;

namespace iCinema.Api.Extensions;

/// <summary>
/// Extension methods for ControllerBase to provide consistent error response formatting.
/// </summary>
public static class ControllerExtensions
{
    /// <summary>
    /// Returns a BadRequest (400) response with a standardized ApiError format.
    /// </summary>
    public static IActionResult BadRequestError(this ControllerBase controller, string message, IDictionary<string, string[]>? details = null)
    {
        return controller.BadRequest(new ApiError
        {
            Status = StatusCodes.Status400BadRequest,
            Error = ErrorMessages.ValidationError,
            Message = message,
            TraceId = controller.HttpContext.TraceIdentifier,
            Details = details
        });
    }

    /// <summary>
    /// Returns a NotFound (404) response with a standardized ApiError format.
    /// </summary>
    public static IActionResult NotFoundError(this ControllerBase controller, string message)
    {
        return controller.NotFound(new ApiError
        {
            Status = StatusCodes.Status404NotFound,
            Error = "Not Found",
            Message = message,
            TraceId = controller.HttpContext.TraceIdentifier
        });
    }

    /// <summary>
    /// Returns a Conflict (409) response with a standardized ApiError format.
    /// </summary>
    public static IActionResult ConflictError(this ControllerBase controller, string message)
    {
        return controller.Conflict(new ApiError
        {
            Status = StatusCodes.Status409Conflict,
            Error = "Conflict",
            Message = message,
            TraceId = controller.HttpContext.TraceIdentifier
        });
    }
}

