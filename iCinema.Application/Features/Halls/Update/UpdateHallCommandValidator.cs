using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.Common.Requests;
using iCinema.Application.DTOs.Hall;

namespace iCinema.Application.Features.Halls.Update;

public class UpdateHallCommandValidator : AbstractValidator<UpdateCommand<HallDto, HallCreateDto>>
{
    private const int MaxCapacity = 1000;
    
    public UpdateHallCommandValidator()
    {
        RuleFor(x => x.Dto.Name)
            .NotEmpty().WithMessage(ErrorMessages.HallNameRequired)
            .MaximumLength(50);

        RuleFor(x => x.Dto.RowsCount)
            .GreaterThan(0).WithMessage(ErrorMessages.RowsCountMustBeGreaterThanZero);

        RuleFor(x => x.Dto.SeatsPerRow)
            .GreaterThan(0).WithMessage(ErrorMessages.SeatsPerRowMustBeGreaterThanZero);

        RuleFor(x => x)
            .Must(x => x.Dto.RowsCount * x.Dto.SeatsPerRow <= MaxCapacity)
            .WithMessage(ErrorMessages.CapacityExceeded(MaxCapacity));

        RuleFor(x => x.Dto.HallType)
            .MaximumLength(50).When(x => !string.IsNullOrWhiteSpace(x.Dto.HallType));

        RuleFor(x => x.Dto.ScreenSize)
            .MaximumLength(50).When(x => !string.IsNullOrWhiteSpace(x.Dto.ScreenSize));

        RuleFor(x => x.Dto.CinemaId)
            .NotEmpty().WithMessage(ErrorMessages.CinemaIdRequired);
    }
}