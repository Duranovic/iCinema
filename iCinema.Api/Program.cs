using FluentValidation.AspNetCore;
using iCinema.Api.Middleware;
using iCinema.Application.DependencyInjection;
using iCinema.Infrastructure.DependencyInjection;
using iCinema.Infrastructure.Identity;
using iCinema.Infrastructure.Persistence;
using iCinema.Infrastructure.Persistence.Seed;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.Services.AddSwaggerGen(); // Registers Swagger generator
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);

// Allow local development requests (Flutter desktop)
builder.Services.AddCors(options =>
{
    options.AddPolicy("DevCors", policy =>
        policy
            .AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod());
});

var app = builder.Build();

// Global exception handling
app.UseMiddleware<ExceptionHandlingMiddleware>();

// Add database seeding here - after app is built but before pipeline configuration
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<iCinemaDbContext>();
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<ApplicationRole>>();
    await DatabaseSeed.SeedAsync(context, userManager, roleManager);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger(); // Enables Swagger middleware to serve OpenAPI JSON
    app.UseSwaggerUI(); // Enables Swagger UI for interactive documentation
}

// Static files for uploaded media
var rootPath = builder.Configuration["FileStorage:RootPath"] ?? "uploads";
var baseUrlPath = builder.Configuration["FileStorage:BaseUrlPath"] ?? "/media";
if (!Path.IsPathRooted(rootPath))
{
    rootPath = Path.Combine(Directory.GetCurrentDirectory(), rootPath);
}
Directory.CreateDirectory(rootPath);
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(rootPath),
    RequestPath = baseUrlPath
});

app.UseHttpsRedirection();

app.UseCors("DevCors");

app.UseAuthorization();

app.MapControllers();

app.Run();