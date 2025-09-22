import 'dart:convert';
import 'package:http/http.dart' as http;

class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['title'],
      imageUrl: json['image'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
    );
  }
}

Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse('https://fakestoreapi.com/products'));
  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}

Future<Product> createProduct(Product product) async {
  final response = await http.post(
    Uri.parse('https://fakestoreapi.com/products'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'title': product.name,
      'price': product.price,
      'description': product.description,
      'category': product.category,
      'image': product.imageUrl,
    }),
  );
  if (response.statusCode == 200 || response.statusCode == 201) {
    return Product.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create product');
  }
}

Future<Product> updateProduct(Product product) async {
  final response = await http.put(
    Uri.parse('https://fakestoreapi.com/products/${product.id}'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'title': product.name,
      'price': product.price,
      'description': product.description,
      'category': product.category,
      'image': product.imageUrl,
    }),
  );
  if (response.statusCode == 200) {
    return Product.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to update product');
  }
}

Future<void> deleteProduct(int id) async {
  final response = await http.delete(
    Uri.parse('https://fakestoreapi.com/products/$id'),
  );
  if (response.statusCode != 200) {
    throw Exception('Failed to delete product');
  }
}
