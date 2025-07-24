using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;

namespace iCinema.Application.Interfaces.Repositories;

public interface IBaseRepository<TDto, TCreateDto, TUpdateDto>
{
    Task<IEnumerable<TDto>> GetAllAsync(CancellationToken cancellationToken);
    Task<TDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken);
    Task<TDto?> CreateAsync(TCreateDto dto, CancellationToken cancellationToken);
    Task<TDto?> UpdateAsync(Guid id, TUpdateDto dto, CancellationToken cancellationToken);
    Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken);
    Task<PagedResult<TDto>> GetFilteredAsync(BaseFilter filter, CancellationToken cancellationToken);
}