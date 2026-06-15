import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStorage {
  Future<String?> readToken();

  Future<String?> readTokenType();

  Future<String?> readUserRole();

  Future<void> saveToken(
    String token, {
    String tokenType = 'bearer',
    String? userRole,
  });

  Future<void> clearToken();
}

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  static const String _tokenKey = 'josi_auth_token';
  static const String _tokenTypeKey = 'josi_auth_token_type';
  static const String _userRoleKey = 'josi_auth_user_role';

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
  Future<String?> readTokenType() async {
    try {
      return _storage.read(key: _tokenTypeKey);
    } on Object {
      return null;
    }
  }

  @override
  Future<String?> readUserRole() async {
    try {
      return _storage.read(key: _userRoleKey);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> saveToken(
    String token, {
    String tokenType = 'bearer',
    String? userRole,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _tokenTypeKey, value: tokenType);
      if (userRole != null && userRole.isNotEmpty) {
        await _storage.write(key: _userRoleKey, value: userRole);
      }
    } on Object {
      return;
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _tokenTypeKey);
      await _storage.delete(key: _userRoleKey);
    } on Object {
      return;
    }
  }
}
