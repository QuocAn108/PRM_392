using PRM392_BE.Model;
using PRM392_BE.Data;
using Microsoft.EntityFrameworkCore;

namespace PRM392_BE.Repositories
{
    public interface IUserRepository
    {
        Task<User?> Login(string username, string password);
        Task Register(string username, string password, string email);
        Task<User?> GetUserById(int id);
    }

    public class UserRepository : IUserRepository
    {
        private readonly AppDBContext _context;

        public UserRepository(AppDBContext context)
        {
            _context = context;
        }

        public async Task<User?> Login(string username, string password)
        {
            return await _context.Users
                .FirstOrDefaultAsync(u => u.Username == username && u.Password == password);
        }

        public async Task Register(string username, string password, string email)
        {
            var user = new User
            {
                Username = username,
                Password = password,
                Email = email
            };
            _context.Users.Add(user);
            await _context.SaveChangesAsync();
        }

        public async Task<User?> GetUserById(int id)
        {
            return await _context.Users.FindAsync(id);
        }
    }
}