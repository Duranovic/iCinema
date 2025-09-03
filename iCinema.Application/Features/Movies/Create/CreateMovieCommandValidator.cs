using FluentValidation;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Movie;

namespace iCinema.Application.Features.Movies.Create;

public class CreateMovieCommandValidator : AbstractValidator<CreateCommand<MovieDto, MovieCreateDto>>
{
    public CreateMovieCommandValidator()
    {
        RuleFor(x => x.Dto.Title)
            .NotEmpty().WithMessage("Title is required.")
            .MaximumLength(200).WithMessage("Title cannot exceed 200 characters.");

        RuleFor(x => x.Dto.ReleaseDate)
            .Must(d => d == null || (d.Value.Year >= 1900 && d.Value.Year <= DateTime.UtcNow.Year + 1))
            .WithMessage("Year must be between 1900 and next year.");

        RuleFor(x => x.Dto.Description)
            .NotEmpty().WithMessage("Description is required.")
            .MaximumLength(1000).WithMessage("Description cannot exceed 1000 characters.");

        RuleFor(x => x.Dto.GenreIds)
            .NotEmpty().WithMessage("At least one genre must be selected.");
    }
}