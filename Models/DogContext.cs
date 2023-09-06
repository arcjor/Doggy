using Microsoft.EntityFrameworkCore;

namespace Doggy.Models;

public class DogContext : DbContext
{
    protected readonly IConfiguration _configuration;

    public DogContext(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseNpgsql(_configuration.GetConnectionString("PostgreSQL"));
    }

    public DbSet<Dog> Dogs { get; set; } = null!;
}
