using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Genres;

namespace iCinema.Application.Features.Genres.Create;

public class CreateGenreCommandValidator : AbstractValidator<GenreCreateDto>
{
    public CreateGenreCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage(ErrorMessages.GenreNameRequired)
            .MaximumLength(50).WithMessage(ErrorMessages.GenreNameMaxLength);
    }
}