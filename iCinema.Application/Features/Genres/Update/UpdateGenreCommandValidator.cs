using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Genres;

namespace iCinema.Application.Features.Genres.Update;

public class UpdateGenreCommandValidator : AbstractValidator<GenreUpdateDto>
{
    public UpdateGenreCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage(ErrorMessages.GenreNameRequired)
            .MaximumLength(50).WithMessage(ErrorMessages.GenreNameMaxLength);
    }
}