using FluentValidation;
using iCinema.Application.DTOs.Genres;

namespace iCinema.Application.Features.Genres.Update;

public class UpdateGenreCommandValidator : AbstractValidator<GenreUpdateDto>
{
    public UpdateGenreCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Genre name is required.")
            .MaximumLength(50).WithMessage("Genre name cannot exceed 50 characters.");
    }
}