using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Country;

namespace iCinema.Application.Features.Countries.Create;

public class CreateCountryCommandValidator : AbstractValidator<CountryCreateDto>
{
    public CreateCountryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage(ErrorMessages.CountryNameRequired)
            .MaximumLength(100).WithMessage(ErrorMessages.CountryNameMaxLength);
    }
}