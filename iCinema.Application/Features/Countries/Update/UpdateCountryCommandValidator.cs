using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Country;

namespace iCinema.Application.Features.Countries.Update;

public class UpdateCountryCommandValidator : AbstractValidator<CountryUpdateDto>
{
    public UpdateCountryCommandValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage(ErrorMessages.CountryNameRequired)
            .MaximumLength(100).WithMessage(ErrorMessages.CountryNameMaxLength);
    }
}