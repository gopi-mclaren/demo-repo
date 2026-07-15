var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

const string ServiceName = "enrollment";
var version = Environment.GetEnvironmentVariable("SERVICE_VERSION") ?? "local";

app.MapGet("/", () => Results.Ok(new
{
    service = ServiceName,
    version,
    status = "running version updated"
}));

app.MapGet("/health", () => Results.Ok(new
{
    service = ServiceName,
    status = "healthy-good"
}));

app.MapGet("/enrollments/{id}", (string id) => Results.Ok(new
{
    service = ServiceName,
    enrollmentId = id,
    status = "active"
}));

app.Run();
