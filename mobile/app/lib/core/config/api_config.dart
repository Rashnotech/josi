class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment('JOSI_API_BASE_URL');

  static bool get isConfigured => baseUrl.trim().isNotEmpty;

  static String get normalizedBaseUrl {
    final String value = baseUrl.trim();
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }
}
