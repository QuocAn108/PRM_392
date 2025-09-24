using PRM392_BE.Model;
using PRM392_BE.Model.DTO;
using PRM392_BE.Repositories;

namespace PRM392_BE.Services
{
    public class ProductService
    {
        private readonly IProductRepository _repo;

        public ProductService(IProductRepository repo)
        {
            _repo = repo;
        }

        public Task<List<Product>> GetAllAsync() => _repo.GetAllAsync();
        public Task<Product?> GetByIdAsync(int id) => _repo.GetByIdAsync(id);

        public Task<Product> AddAsync(CreateProductRequest request)
        {
            var product = new Product
            {
                Title = request.Title,
                Price = request.Price,
                Description = request.Description,
                Category = request.Category,
                Image = request.Image
            };
            return _repo.AddAsync(product);
        }

        public Task<Product?> UpdateAsync(Product product) => _repo.UpdateAsync(product);
        public Task<bool> DeleteAsync(int id) => _repo.DeleteAsync(id);
    }
}