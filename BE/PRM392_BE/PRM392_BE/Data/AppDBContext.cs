using Microsoft.EntityFrameworkCore;
using PRM392_BE.Model;

namespace PRM392_BE.Data
{
    public class AppDBContext : DbContext
    {
        public AppDBContext(DbContextOptions<AppDBContext> options) : base(options)
        {
        }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
        }
         public DbSet<User> Users { get; set; }
         public DbSet<Product> Products { get; set; }
    }
}
