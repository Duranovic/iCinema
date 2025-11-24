using FluentValidation;
using iCinema.Application.Common.Constants;
using iCinema.Application.DTOs.Ratings;

namespace iCinema.Application.Features.Movies.Update;

public class PutMyRatingDtoValidator : AbstractValidator<PutMyRatingDto>
{
    public PutMyRatingDtoValidator()
    {
        RuleFor(x => x.RatingValue)
            .InclusiveBetween((byte)1, (byte)5)
            .WithMessage(ErrorMessages.RatingValueRange);
    }
}

