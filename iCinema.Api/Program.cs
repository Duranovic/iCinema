using iCinema.Api.Extensions;
using iCinema.Api.Middleware;
using iCinema.Application.DependencyInjection;
using iCinema.Infrastructure.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddResponseCaching();
builder.Services.AddOpenApi();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new Microsoft.OpenApi.Models.OpenApiInfo
    {
        Title = "iCinema API",
        Version = "v1",
        Description = "API for iCinema movie theater management system"
    });
    
    // Include XML comments
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        c.IncludeXmlComments(xmlPath);
    }
});
builder.Services.AddApplicationServices();
builder.Services.AddInfrastructureServices(builder.Configuration);
builder.Services.AddApiCors(builder.Configuration);
builder.Services.AddApiAuthorizationPolicies();

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseMiddleware<ExceptionHandlingMiddleware>();
await app.SeedDatabaseAsync();
app.ConfigureSwagger();
app.ConfigureStaticFiles(builder.Configuration);
app.UseHttpsRedirection();
app.UseResponseCaching();
app.UseApiCors(builder.Configuration);
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();