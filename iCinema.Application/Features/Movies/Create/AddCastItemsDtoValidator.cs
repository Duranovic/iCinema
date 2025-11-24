using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Movie;

namespace iCinema.Application.Features.Movies.Create;

public class AddCastItemsDtoValidator : AbstractValidator<AddCastItemsDto>
{
    public AddCastItemsDtoValidator()
    {
        RuleFor(x => x.Items)
            .NotEmpty()
            .WithMessage(ErrorMessages.NoCastItems);
    }
}

