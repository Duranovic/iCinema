using FluentValidation;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Cinema;
using iCinema.Application.DTOs.City;

namespace iCinema.Application.Features.Cities.Create;

public class CreateCityCommandValidator : AbstractValidator<CreateCommand<CityDto, CityCreateDto>>
{
    public CreateCityCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage("Cinema name is required.")
            .MaximumLength(100).WithMessage("Cinema name cannot exceed 100 characters.");

        RuleFor(x => x.Dto.CountryId)
            .Must(id => id != Guid.Empty)
            .WithMessage("CountryId must be a valid GUID.");
    }
}