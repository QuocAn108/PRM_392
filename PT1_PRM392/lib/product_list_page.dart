// product_list_page.dart
import 'package:flutter/material.dart';
import 'product.dart';

// Simple Cart Service
class SimpleCartService {
  static final SimpleCartService _instance = SimpleCartService._internal();
  factory SimpleCartService() => _instance;
  SimpleCartService._internal();

  final Map<int, CartItem> _cartItems = {}; // Sử dụng Map với productId làm key

  List<CartItem> get cartItems => _cartItems.values.toList();
  int get itemCount => _cartItems.values.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems[product.id]!.quantity++;
    } else {
      _cartItems[product.id] = CartItem(product: product, quantity: 1);
    }
  }

  void removeFromCart(Product product) {
    if (_cartItems.containsKey(product.id)) {
      if (_cartItems[product.id]!.quantity > 1) {
        _cartItems[product.id]!.quantity--;
      } else {
        _cartItems.remove(product.id);
      }
    }
  }

  void removeItemCompletely(Product product) {
    _cartItems.remove(product.id);
  }

  void clearCart() {
    _cartItems.clear();
  }

  double get totalPrice {
    return _cartItems.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
}

// Cart Item class
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  final SimpleCartService _cartService = SimpleCartService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final products = await fetchProducts();
      setState(() {
        _products = products;
        _filteredProducts = List.from(_products);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearch() {
    setState(() {
      _filteredProducts = _products
          .where((p) => p.title.toLowerCase().contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  void _showCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Shopping Cart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (_cartService.itemCount > 0)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _cartService.clearCart();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_cartService.itemCount == 0)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Your cart is empty', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _cartService.cartItems.length,
                    itemBuilder: (context, index) {
                      final cartItem = _cartService.cartItems[index];
                      final product = cartItem.product;
                      return Card(
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image),
                            ),
                          ),
                          title: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₫${product.price.toStringAsFixed(0)} x ${cartItem.quantity}'),
                              Text(
                                'Total: ₫${cartItem.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Decrease quantity button
                              if (cartItem.quantity > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.orange, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _cartService.removeFromCart(product);
                                    });
                                    Navigator.pop(context);
                                    _showCart(); // Refresh cart
                                  },
                                  tooltip: 'Decrease quantity',
                                ),
                              // Remove item completely button
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _cartService.removeItemCompletely(product);
                                  });
                                  Navigator.pop(context);
                                  if (_cartService.itemCount > 0) _showCart();
                                },
                                tooltip: 'Remove item',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              if (_cartService.itemCount > 0) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total: ₫${_cartService.totalPrice.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checkout feature coming soon!')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Checkout'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showProductDetail(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          product.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.attach_money, color: Colors.green.shade600, size: 20),
                    Text(
                      '₫${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  product.category,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                product.description,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartService.addToCart(product);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.title} added to cart!'),
                  action: SnackBarAction(
                    label: 'View Cart',
                    onPressed: _showCart,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrEditProduct({Product? product}) async {
    final isEdit = product != null;
    final titleController = TextEditingController(text: product?.title ?? '');
    final imageController = TextEditingController(text: product?.imageUrl ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final descController = TextEditingController(text: product?.description ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isEdit ? Icons.edit : Icons.add, color: Colors.deepPurple),
            const SizedBox(width: 8),
            Text(isEdit ? 'Edit Product' : 'Add New Product'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Product Title',
                    prefixIcon: Icon(Icons.shopping_bag),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (₫)',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Price is required';
                    if (double.tryParse(v) == null || double.parse(v) <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Category is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    prefixIcon: Icon(Icons.image),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Image URL is required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              setState(() => _isLoading = true);
              try {
                if (isEdit) {
                  final updated = await updateProduct(Product(
                    id: product!.id,
                    title: titleController.text.trim(),
                    imageUrl: imageController.text.trim(),
                    price: double.tryParse(priceController.text.trim()) ?? 0,
                    description: descController.text.trim(),
                    category: categoryController.text.trim(),
                  ));
                  final idx = _products.indexWhere((p) => p.id == updated.id);
                  if (idx != -1) {
                    setState(() {
                      _products[idx] = updated;
                      _onSearch();
                      _isLoading = false;
                    });
                  } else {
                    await _fetchData();
                  }
                } else {
                  final created = await createProduct(Product(
                    id: 0,
                    title: titleController.text.trim(),
                    imageUrl: imageController.text.trim(),
                    price: double.tryParse(priceController.text.trim()) ?? 0,
                    description: descController.text.trim(),
                    category: categoryController.text.trim(),
                  ));
                  setState(() {
                    _products.add(created);
                    _onSearch();
                    _isLoading = false;
                  });
                }
              } catch (e) {
                setState(() {
                  _error = e.toString();
                  _isLoading = false;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            child: Text(isEdit ? 'Save Changes' : 'Add Product'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Text('Are you sure you want to delete "${product.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await deleteProduct(product.id);
        setState(() {
          _products.removeWhere((p) => p.id == product.id);
          _onSearch();
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: Colors.deepPurple.shade50,
        actions: [
          // Cart Icon with Badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _showCart,
                tooltip: 'Shopping Cart',
              ),
              if (_cartService.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${_cartService.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch();
                  },
                )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading products...'),
                    ],
                  ),
                ),
              ),
            if (_error != null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            if (!_isLoading && _error == null)
              Expanded(
                child: _filteredProducts.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'No products found matching "${_searchController.text}"'
                            : 'No products available',
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  itemCount: _filteredProducts.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    return Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        title: Text(
                          product.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '₫${product.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              product.category,
                              style: TextStyle(color: Colors.blue.shade600),
                            ),
                          ],
                        ),
                        onTap: () => _showProductDetail(product),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Add to Cart button
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  _cartService.addToCart(product);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.title} added to cart!'),
                                    duration: const Duration(seconds: 2),
                                    action: SnackBarAction(
                                      label: 'View Cart',
                                      onPressed: _showCart,
                                    ),
                                  ),
                                );
                              },
                              tooltip: 'Add to Cart',
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _addOrEditProduct(product: product),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteProduct(product),
                              tooltip: 'Delete',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addOrEditProduct(),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
