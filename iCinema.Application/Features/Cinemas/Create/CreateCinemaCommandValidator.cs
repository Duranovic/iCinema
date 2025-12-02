using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Cinema;

namespace iCinema.Application.Features.Cinemas.Create;

public class CreateCinemaCommandValidator : AbstractValidator<CreateCommand<CinemaDto, CinemaCreateDto>>
{
    public CreateCinemaCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage(ErrorMessages.CinemaNameRequired)
            .MaximumLength(100).WithMessage(ErrorMessages.CinemaNameMaxLength);

        RuleFor(x => x.Dto.Address)
            .NotEmpty().WithMessage(ErrorMessages.AddressRequired)
            .MaximumLength(200).WithMessage(ErrorMessages.AddressMaxLength);

        RuleFor(x => x.Dto.CityId)
            .Must(id => id != Guid.Empty)
            .WithMessage(ErrorMessages.CityIdRequired);

        RuleFor(x => x.Dto.Email)
            .EmailAddress().When(x => !string.IsNullOrWhiteSpace(x.Dto.Email))
            .WithMessage(ErrorMessages.InvalidEmailFormat);

        RuleFor(x => x.Dto.PhoneNumber)
            .Matches(@"^\+?[\d\s\-\(\)]{7,20}$").When(x => !string.IsNullOrWhiteSpace(x.Dto.PhoneNumber))
            .WithMessage(ErrorMessages.InvalidPhoneFormat);
    }
}