using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs;

namespace iCinema.Application.Features.Projections.Update;

public class UpdateProjectionCommandValidator : AbstractValidator<UpdateCommand<ProjectionDto, ProjectionUpdateDto>>
{
    public UpdateProjectionCommandValidator()
    {
        RuleFor(x => x.Dto.MovieId)
            .Must(id => id != Guid.Empty)
            .WithMessage(ErrorMessages.MovieIdRequired);

        RuleFor(x => x.Dto.HallId)
            .Must(id => id != Guid.Empty)
            .WithMessage(ErrorMessages.HallIdRequired);

        RuleFor(x => x.Dto.StartTime)
            .NotEmpty().WithMessage(ErrorMessages.StartTimeRequired)
            .GreaterThan(DateTime.UtcNow).WithMessage(ErrorMessages.StartTimeMustBeFuture);
        
        RuleFor(x => x)
            .Must(x => x.Dto.StartTime > DateTime.UtcNow)
            .WithMessage(ErrorMessages.ProjectionAlreadyStarted);
    }
}