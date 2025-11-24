using iCinema.Api.Extensions;
using iCinema.Api.Middleware;
using iCinema.Application.DependencyInjection;
using iCinema.Infrastructure.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddSwaggerGen();
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddApiCors(builder.Configuration);

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseMiddleware<ExceptionHandlingMiddleware>();
await app.SeedDatabaseAsync();
app.ConfigureSwagger();
app.ConfigureStaticFiles(builder.Configuration);
app.UseHttpsRedirection();
app.UseApiCors(builder.Configuration);
app.UseAuthorization();
app.MapControllers();

app.Run();