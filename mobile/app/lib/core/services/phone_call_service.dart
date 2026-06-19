import 'package:flutter/services.dart';

class PhoneCallService {
  const PhoneCallService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('josi_ride/phone');

  final MethodChannel _channel;

  Future<bool> call(String phoneNumber) async {
    final String normalized = phoneNumber.trim();
    if (normalized.isEmpty) {
      return false;
    }

    try {
      final Object? result = await _channel.invokeMethod<Object?>(
        'dial',
        <String, Object?>{'phone': normalized},
      );
      return result == true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}
