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
        var products = JsonSerializer.Deserialize<List<Product>>(response, new JsonSerializerOptions
        {
            PropertyNameCaseInsensitive = true
        });

        if (products != null)
        {
            context.Products.AddRange(products);
            await context.SaveChangesAsync();
        }
    }
}