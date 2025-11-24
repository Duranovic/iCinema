using System.Linq.Expressions;
using AutoMapper;
using AutoMapper.QueryableExtensions;
using iCinema.Application.Common.Filters;
using iCinema.Application.Common.Models;
using iCinema.Application.Interfaces;
using iCinema.Application.Interfaces.Repositories;
using iCinema.Infrastructure.Persistence.Models;
using Microsoft.EntityFrameworkCore;

namespace iCinema.Infrastructure.Persistence.Repositories;

public class BaseRepository<TEntity, TDto, TCreateDto, TUpdateDto>(iCinemaDbContext context, IMapper mapper, IUnitOfWork unitOfWork)
    : IBaseRepository<TDto, TCreateDto, TUpdateDto>
    where TEntity : class
{
    protected readonly DbSet<TEntity> DbSet = context.Set<TEntity>();

    protected virtual string[] SearchableFields => [];

    protected virtual IQueryable<TEntity> AddFilter(IQueryable<TEntity> query, BaseFilter filter)
    {
        if (filter is null) return query;  // Override in child repositories for custom filtering

        // Choose a safe default
        if (filter.SortBy != null)
        {
            var sortBy = string.IsNullOrWhiteSpace(filter.SortBy) ? "CreatedAt" : filter.SortBy!;
            var desc   = filter.Descending;

            // Map the sort property to the actual entity property if needed
            var actualSortProperty = GetActualSortProperty(sortBy);

            // Dynamic order using EF.Property so it translates to SQL
            query = desc
                ? query.OrderByDescending(e => EF.Property<object?>(e, actualSortProperty))
                : query.OrderBy(e => EF.Property<object?>(e, actualSortProperty));    
        }
       
        return query;
    }

    protected virtual IQueryable<TEntity> AddInclude(IQueryable<TEntity> query)
    {
        return query; // Override in child repositories for eager loading
    }

    protected virtual string GetActualSortProperty(string requestedProperty)
    {
        // Override in child repositories for entity-specific property mappings
        return requestedProperty;
    }

    protected virtual Task BeforeInsert(TEntity entity, TCreateDto dto)
    {
        return Task.CompletedTask; // Override in child repositories for validation/business rules
    }

    public virtual async Task<IEnumerable<TDto>> GetAllAsync(CancellationToken cancellationToken)
    {
        var query = DbSet.AsQueryable();
        
        // Filter out soft-deleted entities if the entity implements ISoftDeletable
        if (typeof(ISoftDeletable).IsAssignableFrom(typeof(TEntity)))
        {
            query = query.Where(e => !((ISoftDeletable)e).IsDeleted);
        }
        
        return await query
            .ProjectTo<TDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);
    }

    public virtual async Task<TDto?> GetByIdAsync(Guid id, CancellationToken cancellationToken)
    {
        var query = DbSet.Where(e => EF.Property<Guid>(e, "Id") == id);
        
        // Filter out soft-deleted entities if the entity implements ISoftDeletable
        if (typeof(ISoftDeletable).IsAssignableFrom(typeof(TEntity)))
        {
            query = query.Where(e => !((ISoftDeletable)e).IsDeleted);
        }
        
        return await query
            .ProjectTo<TDto>(mapper.ConfigurationProvider)
            .FirstOrDefaultAsync(cancellationToken);
    }

    public virtual async Task<TDto?> CreateAsync(TCreateDto dto, CancellationToken cancellationToken)
    {
        var entity = mapper.Map<TEntity>(dto);
        await BeforeInsert(entity, dto);

        await DbSet.AddAsync(entity, cancellationToken);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return mapper.Map<TDto>(entity);
    }

    public virtual async Task<TDto?> UpdateAsync(Guid id, TUpdateDto dto, CancellationToken cancellationToken)
    {
        var entity = await DbSet.FindAsync([id], cancellationToken);
        if (entity == null) return default;

        mapper.Map(dto, entity);
        await unitOfWork.SaveChangesAsync(cancellationToken);

        return mapper.Map<TDto>(entity);
    }

    public virtual async Task<bool> DeleteAsync(Guid id, CancellationToken cancellationToken)
    {
        var entity = await DbSet.FindAsync([id], cancellationToken);
        if (entity == null) return false;

        // Soft delete if entity implements ISoftDeletable, otherwise hard delete
        if (entity is ISoftDeletable softDeletable)
        {
            softDeletable.IsDeleted = true;
            softDeletable.DeletedAt = DateTime.UtcNow;
        }
        else
        {
            DbSet.Remove(entity);
        }
        
        await unitOfWork.SaveChangesAsync(cancellationToken);
        return true;
    }

    public virtual async Task<PagedResult<TDto>> GetFilteredAsync(BaseFilter filter, CancellationToken cancellationToken)
    {
        var query = DbSet.AsQueryable();
        
        // Filter out soft-deleted entities if the entity implements ISoftDeletable
        if (typeof(ISoftDeletable).IsAssignableFrom(typeof(TEntity)))
        {
            query = query.Where(e => !((ISoftDeletable)e).IsDeleted);
        }
        
        query = AddInclude(query);
        query = AddFilter(query, filter);

        // Search
        if (!string.IsNullOrWhiteSpace(filter.Search) && SearchableFields.Any())
        {
            var parameter = Expression.Parameter(typeof(TEntity), "e");
            Expression? combined = null;

            // Prepare EF.Functions.Like(DbFunctions, string, string)
            var likeMethod = typeof(DbFunctionsExtensions).GetMethod(
                name: "Like",
                types: new[] { typeof(DbFunctions), typeof(string), typeof(string) }
            );
            var efFunctions = Expression.Property(null, typeof(EF), nameof(EF.Functions));
            var pattern = Expression.Constant($"%{filter.Search}%", typeof(string));

            foreach (var field in SearchableFields)
            {
                var property = Expression.Property(parameter, field);

                // Only apply to string properties; skip others to keep the query translatable
                if (property.Type != typeof(string))
                {
                    continue;
                }

                // Build: property != null && EF.Functions.Like(property, "%search%")
                var notNull = Expression.NotEqual(property, Expression.Constant(null, typeof(string)));
                var likeCall = Expression.Call(likeMethod!, efFunctions, property, pattern);
                var thisFieldExpr = Expression.AndAlso(notNull, likeCall);

                combined = combined == null ? thisFieldExpr : Expression.OrElse(combined, thisFieldExpr);
            }

            if (combined != null)
            {
                var lambda = Expression.Lambda<Func<TEntity, bool>>(combined, parameter);
                query = query.Where(lambda);
            }
        }

        var totalCount = await query.CountAsync(cancellationToken);

        // Sorting is handled in AddFilter method

        // Pagination
        if (!filter.DisablePaging)
        {
            query = query.Skip((filter.Page - 1) * filter.PageSize).Take(filter.PageSize);
        }

        var items = await query
            .ProjectTo<TDto>(mapper.ConfigurationProvider)
            .ToListAsync(cancellationToken);

        return new PagedResult<TDto>
        {
            Items = items,
            TotalCount = totalCount,
            Page = filter.DisablePaging ? 1 : filter.Page,
            PageSize = filter.DisablePaging ? totalCount : filter.PageSize
        };
    }
}