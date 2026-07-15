var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

const string ServiceName = "filemanagement";
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
    status = "healthy-good"
}));

app.MapGet("/files/{id}", (string id) => Results.Ok(new
{
    service = ServiceName,
    fileId = id,
    status = "stored"
}));

app.Run();
