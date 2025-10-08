import 'dart:convert';
import '../models/user.dart';
import '../config/environment.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        EnvironmentConfig.loginEndpoint,
        {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        // Giả sử backend trả về user info hoặc token
        // Điều chỉnh theo response thực tế từ API của bạn
        _currentUser = User(
          id: 1,
          username: username,
          email: '',
          firstName: '',
          lastName: '',
          token: '',
        );

        return _currentUser!;
      } else {
        throw Exception('Invalid username or password');
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }
}
