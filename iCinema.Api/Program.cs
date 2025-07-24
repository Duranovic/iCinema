using FluentValidation.AspNetCore;
using iCinema.Api.Middleware;
using iCinema.Application.DependencyInjection;
using iCinema.Infrastructure.DependencyInjection;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Seed;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.Services.AddSwaggerGen(); // Registers Swagger generator
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

var app = builder.Build();

// Global exception handling
app.UseMiddleware<ExceptionHandlingMiddleware>();

// Add database seeding here - after app is built but before pipeline configuration
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<iCinemaDbContext>();
    // Seed the database
    DatabaseSeed.Seed(context);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger(); // Enables Swagger middleware to serve OpenAPI JSON
    app.UseSwaggerUI(); // Enables Swagger UI for interactive documentation
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();