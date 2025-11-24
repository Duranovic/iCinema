using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.DTOs.Director;
using iCinema.Application.DTOs.Metadata;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

    public class DirectorRepository(iCinemaDbContext context, IMapper mapper, IUnitOfWork unitOfWork)
        : BaseRepository<Director, DirectorDto, DirectorCreateDto, DirectorUpdateDto>(context, mapper, unitOfWork), IDirectorRepository
    {
        protected override string[] SearchableFields => ["FullName"];    

        public async Task<IEnumerable<DirectorItemDto>> GetItemsAsync(CancellationToken cancellationToken = default)
        {
            return await DbSet
                .AsNoTracking()
                .OrderBy(d => d.FullName)
                .Select(d => new DirectorItemDto
                {
                    Id = d.Id,
                    FullName = d.FullName
                })
                .ToListAsync(cancellationToken);
        }

        public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
        {
            var inUse = await DbSet.AnyAsync(d => d.Id == id && d.Movies.Any(), cancellationToken);
            if (inUse)
            {
                throw new BusinessRuleException("Ne možete obrisati režisera jer je povezan s filmovima.");
            }

            return await base.DeleteAsync(id, cancellationToken);
        }
    }
