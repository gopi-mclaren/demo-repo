var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

const string ServiceName = "reporting";
var version = Environment.GetEnvironmentVariable("SERVICE_VERSION") ?? "local";

app.MapGet("/", () => Results.Ok(new
{
    service = ServiceName,
    version,
    status = "running"
}));

app.MapGet("/health", () => Results.Ok(new
{
    service = ServiceName,
    status = "healthy"
}));

app.MapGet("/reports/{id}", (string id) => Results.Ok(new
{
    service = ServiceName,
    reportId = id,
    status = "generated"
}));

app.Run();
