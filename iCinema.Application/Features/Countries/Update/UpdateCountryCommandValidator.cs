using FluentValidation;
using iCinema.Application.DTOs.Country;

namespace iCinema.Application.Features.Countries.Update;

public class UpdateCountryCommandValidator : AbstractValidator<CountryUpdateDto>
{
    public UpdateCountryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Country name is required.")
            .MaximumLength(100).WithMessage("Country name cannot exceed 100 characters.");
    }
}