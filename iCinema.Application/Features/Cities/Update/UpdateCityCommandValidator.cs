using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;

namespace iCinema.Application.Features.Cities.Update;

public class UpdateCityCommandValidator : AbstractValidator<UpdateCommand<CityDto, CityUpdateDto>>
{
    public UpdateCityCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage(ErrorMessages.CityNameRequired)
            .MaximumLength(100).WithMessage(ErrorMessages.CityNameMaxLength);

        RuleFor(x => x.Dto.CountryId)
            .Must(id => id != Guid.Empty)
            .WithMessage(ErrorMessages.CountryIdRequired);
    }
}