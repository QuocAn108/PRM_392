using System.Net.Http;
using System.Text.Json;
using PRM392_BE.Data;
using PRM392_BE.Model;

public static class DataSeeder
{
    public static async Task SeedProductsAsync(AppDBContext context)
    {
        if (context.Products.Any()) return;

        using var httpClient = new HttpClient();
        var response = await httpClient.GetStringAsync("https://fakestoreapi.com/products");
        var productsFromApi = JsonSerializer.Deserialize<List<Product>>(response, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (productsFromApi != null)
        {
            var products = productsFromApi.Select(p => new Product
            {
                // KHÔNG gán Id, để database tự sinh
                Title = p.Title,
                Price = p.Price,
                Description = p.Description,
                Category = p.Category,
                Image = p.Image
            }).ToList();

            context.Products.AddRange(products);
            await context.SaveChangesAsync();
        }
    }
}