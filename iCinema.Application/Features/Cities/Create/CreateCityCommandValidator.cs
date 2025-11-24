using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.DTOs.City;

namespace iCinema.Application.Features.Cities.Create;

public class CreateCityCommandValidator : AbstractValidator<CreateCommand<CityDto, CityCreateDto>>
{
    public CreateCityCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage(ErrorMessages.CityNameRequired)
            .MaximumLength(100).WithMessage(ErrorMessages.CityNameMaxLength);

        RuleFor(x => x.Dto.CountryId)
            .Must(id => id != Guid.Empty)
            .WithMessage(ErrorMessages.CountryIdRequired);
    }
}