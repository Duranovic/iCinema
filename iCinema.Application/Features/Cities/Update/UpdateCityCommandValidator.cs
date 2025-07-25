using FluentValidation;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs;
using iCinema.Application.DTOs.City;

namespace iCinema.Application.Features.Cities.Update;

public class UpdateCityCommandValidator : AbstractValidator<UpdateCommand<CityDto, CityUpdateDto>>
{
    public UpdateCityCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage("Cinema name is required.")
            .MaximumLength(100).WithMessage("Cinema name cannot exceed 100 characters.");

        RuleFor(x => x.Dto.CountryId)
            .Must(id => id != Guid.Empty)
            .WithMessage("CountryId must be a valid GUID.");
    }
}