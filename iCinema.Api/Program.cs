using iCinema.Api.Extensions;
using iCinema.Api.Hubs;
using iCinema.Api.Middleware;
using iCinema.Api.Services;
using iCinema.Application.DependencyInjection;
using iCinema.Application.Interfaces.Services;
using iCinema.Infrastructure.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

// Configure Kestrel for HTTPS
builder.WebHost.ConfigureKestrel(options =>
{
    var httpsPort = builder.Configuration.GetValue<int>("ASPNETCORE_HTTPS_PORT", 7026);
    var httpPort = 5218;
    
    options.ListenAnyIP(httpPort, listenOptions =>
    {
        listenOptions.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http1AndHttp2;
    });
    
    options.ListenAnyIP(httpsPort, listenOptions =>
    {
        listenOptions.Protocols = Microsoft.AspNetCore.Server.Kestrel.Core.HttpProtocols.Http1AndHttp2;
        
        // Try to use a certificate file if it exists (for Docker), otherwise use default
        var certPath = Path.Combine(AppContext.BaseDirectory, "https-dev.crt");
        var keyPath = Path.Combine(AppContext.BaseDirectory, "https-dev.key");
        
        if (File.Exists(certPath) && File.Exists(keyPath))
        {
            // Load certificate from PEM files
            var cert = System.Security.Cryptography.X509Certificates.X509Certificate2.CreateFromPemFile(certPath, keyPath);
            listenOptions.UseHttps(cert);
        }
        else
        {
            // Use default certificate (development certificate)
            listenOptions.UseHttps();
        }
    });
});

// Add services to the container
builder.Services.AddControllers();

// Configure routing to use lowercase URLs
builder.Services.Configure<Microsoft.AspNetCore.Routing.RouteOptions>(options =>
{
    options.LowercaseUrls = true;
    options.LowercaseQueryStrings = true;
});
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
builder.Services.AddSignalR();
builder.Services.AddScoped<INotificationsPushService, NotificationsPushService>();

var app = builder.Build();

// Configure the HTTP request pipeline
app.UseMiddleware<ExceptionHandlingMiddleware>();
await app.MigrateDatabaseAsync();
await app.SeedDatabaseAsync();
app.ConfigureSwagger();
app.ConfigureStaticFiles(builder.Configuration);
app.UseHttpsRedirection();
app.UseResponseCaching();
app.UseApiCors(builder.Configuration);
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<NotificationsHub>("/hubs/notifications");

app.Run();