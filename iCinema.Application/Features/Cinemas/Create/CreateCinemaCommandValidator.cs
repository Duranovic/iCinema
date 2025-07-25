using FluentValidation;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Cinema;

namespace iCinema.Application.Features.Cinemas.Create;

public class CreateCinemaCommandValidator : AbstractValidator<CreateCommand<CinemaDto, CinemaCreateDto>>
{
    public CreateCinemaCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage("Cinema name is required.")
            .MaximumLength(100).WithMessage("Cinema name cannot exceed 100 characters.");

        RuleFor(x => x.Dto.Address)
            .NotEmpty().WithMessage("Address is required.")
            .MaximumLength(200).WithMessage("Address cannot exceed 200 characters.");

        RuleFor(x => x.Dto.CityId)
            .NotEmpty().WithMessage("CityId is required.");

        RuleFor(x => x.Dto.Email)
            .EmailAddress().When(x => !string.IsNullOrWhiteSpace(x.Dto.Email))
            .WithMessage("Invalid email format.");

        RuleFor(x => x.Dto.PhoneNumber)
            .Matches(@"^\+?[0-9]{7,15}$").When(x => !string.IsNullOrWhiteSpace(x.Dto.PhoneNumber))
            .WithMessage("Invalid phone number format.");
    }
}