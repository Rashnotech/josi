import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readToken();

  Future<void> saveToken(String token);

  Future<void> clearToken();
}

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _tokenKey = 'josi_auth_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() async {
    try {
      return _storage.read(key: _tokenKey);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } on Object {
      return;
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } on Object {
      return;
    }
  }
}
