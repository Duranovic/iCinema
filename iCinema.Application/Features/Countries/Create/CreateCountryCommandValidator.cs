using FluentValidation;
using iCinema.Application.DTOs.Country;

namespace iCinema.Application.Features.Countries.Create;

public class CreateCountryCommandValidator : AbstractValidator<CountryCreateDto>
{
    public CreateCountryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Country name is required.")
            .MaximumLength(100).WithMessage("Country name cannot exceed 100 characters.");
    }
}