using AutoMapper;
using iCinema.Application.Common.Exceptions;
using iCinema.Application.Common.Filters;
using iCinema.Application.DTOs.Hall;
using iCinema.Application.DTOs.Movie;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class HallRepository(iCinemaDbContext context, IMapper mapper, IUnitOfWork unitOfWork, IProjectionRulesService projectionRulesService) : BaseRepository<Hall, HallDto, HallCreateDto, HallUpdateDto>(context, mapper, unitOfWork), IHallRepository
{
    private readonly iCinemaDbContext _context = context;
    private readonly IMapper _mapper = mapper;
    private readonly IProjectionRulesService _projectionRulesService = projectionRulesService;
    protected override string[] SearchableFields => ["Title", "Description"];
    
    protected override IQueryable<Hall> AddInclude(IQueryable<Hall> query)
    {
        return query.Include(m => m.Cinema);
    }
    
    protected override IQueryable<Hall> AddFilter(IQueryable<Hall> query, BaseFilter baseFilter)
    {
        if (baseFilter is not HallFilter filter) return query;
        
        if (filter.CinemaId.HasValue)
            query = query.Where(m => m.CinemaId == filter.CinemaId);
        return query;
    }
    
    protected override Task BeforeInsert(Hall entity, HallCreateDto dto)
    {
        // Ensure the Hall has an ID so we can set FK on seats
        if (entity.Id == Guid.Empty)
            entity.Id = Guid.NewGuid();

        // Generate seats rows × seatsPerRow
        if (dto.RowsCount > 0 && dto.SeatsPerRow > 0)
        {
            var seats = new List<Seat>(dto.RowsCount * dto.SeatsPerRow);
            for (var r = 1; r <= dto.RowsCount; r++)
            {
                for (var s = 1; s <= dto.SeatsPerRow; s++)
                {
                    seats.Add(new Seat
                    {
                        Id = Guid.NewGuid(),
                        HallId = entity.Id,
                        RowNumber = r,
                        SeatNumber = s
                    });
                }
            }

            // Attach to entity so EF saves in same transaction
            foreach (var seat in seats)
                entity.Seats.Add(seat);
        }

        return Task.CompletedTask;
    }
    
    public override async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var hall = await DbSet
            .Include(h => h.Projections)
            .Include(h => h.Seats)
            .FirstOrDefaultAsync(h => h.Id == id, cancellationToken);

        if (hall == null)
            return false;

        // Delete all projections (past, future, and inactive) - they will be removed with the hall
        _context.Projections.RemoveRange(hall.Projections);

        // Delete seats
        _context.Seats.RemoveRange(hall.Seats);

        // Delete hall
        DbSet.Remove(hall);

        await unitOfWork.SaveChangesAsync(cancellationToken);

        return true;
    }
}