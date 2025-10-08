class EnvironmentConfig {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:5228/api'
  );

  // API endpoints
  static const String productsEndpoint = '/Product';
  static const String loginEndpoint = '/User/login';
}
