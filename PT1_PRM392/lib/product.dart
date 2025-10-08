import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config/environment.dart';

class Product {
  final int id;
  final String title;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['image'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'image': imageUrl,
    };
  }
}


Future<List<Product>> fetchProducts() async {
  try {
    final response = await http.get(
      Uri.parse('${EnvironmentConfig.baseUrl}${EnvironmentConfig.productsEndpoint}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<Product> createProduct(Product product) async {
  try {
    final response = await http.post(
      Uri.parse('${EnvironmentConfig.baseUrl}${EnvironmentConfig.productsEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create product: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<Product> updateProduct(Product product) async {
  try {
    final response = await http.put(
      Uri.parse('${EnvironmentConfig.baseUrl}${EnvironmentConfig.productsEndpoint}/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return Product.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update product: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<void> deleteProduct(int id) async {
  try {
    final response = await http.delete(
      Uri.parse('${EnvironmentConfig.baseUrl}${EnvironmentConfig.productsEndpoint}/$id'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}