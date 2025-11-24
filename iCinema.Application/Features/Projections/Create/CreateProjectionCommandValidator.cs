using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs;

namespace iCinema.Application.Features.Projections.Create;

public class CreateProjectionCommandValidator : AbstractValidator<CreateCommand<ProjectionDto, ProjectionCreateDto>>
{
    public CreateProjectionCommandValidator()
    {
        RuleFor(x => x.Dto.MovieId)
            .NotEmpty().WithMessage(ErrorMessages.MovieIdRequired);

        RuleFor(x => x.Dto.HallId)
            .NotEmpty().WithMessage(ErrorMessages.HallIdRequired);

        RuleFor(x => x.Dto.StartTime)
            .NotEmpty().WithMessage(ErrorMessages.StartTimeRequired)
            .GreaterThan(DateTime.UtcNow).WithMessage(ErrorMessages.StartTimeMustBeFuture);
        
        RuleFor(x => x)
            .Must(x => x.Dto.StartTime > DateTime.UtcNow)
            .WithMessage(ErrorMessages.ProjectionAlreadyStarted);
    }
}