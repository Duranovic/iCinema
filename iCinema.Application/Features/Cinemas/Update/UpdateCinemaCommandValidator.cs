using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Cinema;

namespace iCinema.Application.Features.Cinemas.Update;

public class UpdateCinemaCommandValidator : AbstractValidator<UpdateCommand<CinemaDto, CinemaUpdateDto>>
{
    public UpdateCinemaCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage(ErrorMessages.CinemaNameRequired)
            .MaximumLength(100).WithMessage(ErrorMessages.CinemaNameMaxLength);

        RuleFor(x => x.Dto.Address)
            .NotEmpty().WithMessage(ErrorMessages.AddressRequired)
            .MaximumLength(200).WithMessage(ErrorMessages.AddressMaxLength);

        RuleFor(x => x.Dto.CityId)
            .NotEmpty().WithMessage(ErrorMessages.CityIdRequired);

        RuleFor(x => x.Dto.Email)
            .EmailAddress().When(x => !string.IsNullOrWhiteSpace(x.Dto.Email))
            .WithMessage(ErrorMessages.InvalidEmailFormat);

        RuleFor(x => x.Dto.PhoneNumber)
            .Matches(@"^\+?[0-9]{7,15}$").When(x => !string.IsNullOrWhiteSpace(x.Dto.PhoneNumber))
            .WithMessage(ErrorMessages.InvalidPhoneFormat);
    }
}