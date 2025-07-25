using FluentValidation;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs;

namespace iCinema.Application.Features.Projections.Update;

public class UpdateProjectionCommandValidator : AbstractValidator<UpdateCommand<ProjectionDto, ProjectionUpdateDto>>
{
    public UpdateProjectionCommandValidator()
    {
        RuleFor(x => x.Dto.MovieId)
            .NotEmpty().WithMessage("MovieId is required.");

        RuleFor(x => x.Dto.HallId)
            .NotEmpty().WithMessage("HallId is required.");

        RuleFor(x => x.Dto.StartTime)
            .NotEmpty().WithMessage("StartTime is required.")
            .GreaterThan(DateTime.UtcNow).WithMessage("StartTime must be in the future.");
        
        RuleFor(x => x)
            .Must(x => x.Dto.StartTime > DateTime.UtcNow)
            .WithMessage("Cannot update a projection that has already started.");
    }
}