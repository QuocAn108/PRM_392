using PRM392_BE.Model;
using PRM392_BE.Repositories;

namespace PRM392_BE.Services
{
    public class UserService
    {
        private readonly IUserRepository _repo;

        public UserService(IUserRepository repo)
        {
            _repo = repo;
        }

        public Task<User?> Login(string username, string password) => _repo.Login(username, password);
        public Task Register(string username, string password, string email) => _repo.Register(username, password, email);
        public Task<User?> GetUserById(int id) => _repo.GetUserById(id);
    }
}