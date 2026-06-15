import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';

typedef ApiHttpRequest = Future<ApiHttpResponse> Function(
  Uri uri, {
  required String method,
  required Map<String, String> headers,
  Object? body,
});

class ApiHttpResponse {
  const ApiHttpResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}

class ApiException implements Exception {
  const ApiException(this.message, {this.errors = const <String, Object?>{}});

  final String message;
  final Map<String, Object?> errors;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    String? baseUrl,
    ApiHttpRequest? httpRequest,
  })  : _baseUrl = (baseUrl ?? ApiConfig.normalizedBaseUrl).trim(),
        _httpRequest = httpRequest ?? _defaultHttpRequest;

  final String _baseUrl;
  final ApiHttpRequest _httpRequest;

  bool get isConfigured => _baseUrl.isNotEmpty;

  Future<Map<String, Object?>> get(
    String path, {
    String? token,
  }) {
    return _send(path, method: 'GET', token: token);
  }

  Future<Map<String, Object?>> post(
    String path, {
    Map<String, Object?> body = const <String, Object?>{},
    String? token,
  }) {
    return _send(path, method: 'POST', body: body, token: token);
  }

  Future<Map<String, Object?>> _send(
    String path, {
    required String method,
    Map<String, Object?> body = const <String, Object?>{},
    String? token,
  }) async {
    if (!isConfigured) {
      throw const ApiException('API base URL is not configured.');
    }

    final ApiHttpResponse response;
    try {
      response = await _httpRequest(
        Uri.parse('$_baseUrl$path'),
        method: method,
        headers: <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
        },
        body: method == 'GET' ? null : jsonEncode(body),
      );
    } on SocketException {
      throw const ApiException(
          'Network connection failed. Please check your internet and try again.');
    } on HandshakeException {
      throw const ApiException(
          'Secure connection failed. Please try again later.');
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    }

    final Object? decoded;
    try {
      decoded = response.body.isEmpty
          ? <String, Object?>{}
          : jsonDecode(response.body);
    } on FormatException {
      throw const ApiException('Unexpected server response.');
    }

    if (decoded is! Map) {
      throw const ApiException('Unexpected server response.');
    }
    final Map<String, Object?> envelope = decoded.map(
      (Object? key, Object? value) => MapEntry<String, Object?>('$key', value),
    );

    final bool ok = response.statusCode >= 200 &&
        response.statusCode < 300 &&
        envelope['status'] != false;
    if (!ok) {
      throw ApiException(
        (envelope['message'] as String?) ??
            _messageForStatus(response.statusCode),
        errors: _errorsFromJson(envelope['errors']),
      );
    }

    return envelope;
  }

  static Map<String, Object?> dataFromEnvelope(Map<String, Object?> envelope) {
    final Object? data = envelope['data'];
    if (data is Map) {
      return data.map(
        (Object? key, Object? value) =>
            MapEntry<String, Object?>('$key', value),
      );
    }

    return envelope;
  }

  static String messageFromEnvelope(Map<String, Object?> envelope) {
    return (envelope['message'] as String?) ?? '';
  }

  static Map<String, Object?> _errorsFromJson(Object? value) {
    if (value is Map) {
      return value.map(
        (Object? key, Object? fieldValue) =>
            MapEntry<String, Object?>('$key', fieldValue),
      );
    }

    return const <String, Object?>{};
  }

  static String _messageForStatus(int statusCode) {
    return switch (statusCode) {
      401 => 'Please sign in again to continue.',
      403 => 'You do not have permission to access this resource.',
      422 => 'Please check the highlighted fields and try again.',
      >= 500 => 'The server could not complete the request. Please try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }

  static Future<ApiHttpResponse> _defaultHttpRequest(
    Uri uri, {
    required String method,
    required Map<String, String> headers,
    Object? body,
  }) async {
    final HttpClient client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final HttpClientRequest request = method == 'GET'
          ? await client.getUrl(uri)
          : await client.postUrl(uri);
      headers.forEach(request.headers.set);
      if (body != null) {
        request.write(body is String ? body : jsonEncode(body));
      }

      final HttpClientResponse response =
          await request.close().timeout(const Duration(seconds: 16));
      final String responseBody = await utf8.decoder.bind(response).join();
      return ApiHttpResponse(
        statusCode: response.statusCode,
        body: responseBody,
      );
    } finally {
      client.close(force: true);
    }
  }
}
