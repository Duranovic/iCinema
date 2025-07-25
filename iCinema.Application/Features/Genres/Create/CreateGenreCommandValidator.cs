using FluentValidation;
using iCinema.Application.DTOs.Genres;

namespace iCinema.Application.Features.Genres.Create;

public class CreateGenreCommandValidator : AbstractValidator<GenreCreateDto>
{
    public CreateGenreCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Genre name is required.")
            .MaximumLength(50).WithMessage("Genre name cannot exceed 50 characters.");
    }
}