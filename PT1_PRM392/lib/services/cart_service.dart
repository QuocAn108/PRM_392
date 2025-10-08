import '../models/cart.dart';
import '../models/product.dart';

class CartService {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(Product product, {int quantity = 1}) {
    _cart.addItem(product, quantity: quantity);
  }

  void removeFromCart(int productId) {
    _cart.removeItem(productId);
  }

  void updateQuantity(int productId, int quantity) {
    _cart.updateQuantity(productId, quantity);
  }

  void clearCart() {
    _cart.clear();
  }

  int getProductQuantity(int productId) {
    final item = _cart.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: Product(id: 0, title: '', imageUrl: '', price: 0, description: '', category: ''), quantity: 0),
    );
    return item.quantity;
  }

  bool isInCart(int productId) {
    return _cart.items.any((item) => item.product.id == productId);
  }

  double get totalPrice => _cart.totalPrice;
  int get totalItems => _cart.totalItems;
  bool get isEmpty => _cart.isEmpty;
  List<CartItem> get items => _cart.items;
}
