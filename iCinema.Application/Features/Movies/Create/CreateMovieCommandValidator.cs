using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Movie;

namespace iCinema.Application.Features.Movies.Create;

public class CreateMovieCommandValidator : AbstractValidator<CreateCommand<MovieDto, MovieCreateDto>>
{
    public CreateMovieCommandValidator()
    {
        RuleFor(x => x.Dto.Title)
            .NotEmpty().WithMessage(ErrorMessages.TitleRequired)
            .MaximumLength(200).WithMessage(ErrorMessages.TitleMaxLength);

        RuleFor(x => x.Dto.ReleaseDate)
            .Must(d => d == null || (d.Value.Year >= 1900 && d.Value.Year <= DateTime.UtcNow.Year + 1))
            .WithMessage(ErrorMessages.YearRange);

        RuleFor(x => x.Dto.Description)
            .NotEmpty().WithMessage(ErrorMessages.DescriptionRequired)
            .MaximumLength(1000).WithMessage(ErrorMessages.DescriptionMaxLength);

        RuleFor(x => x.Dto.GenreIds)
            .NotEmpty().WithMessage(ErrorMessages.GenreRequired);
    }
}