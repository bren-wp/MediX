import 'package:flutter/services.dart';

abstract final class MedixPlatformNavigation {
  static const _channel =
      MethodChannel('com.brendigo.medix/navigation');

  static Future<bool> openExternalUrl(String url) async {
    return await _channel.invokeMethod<bool>(
          'openExternalUrl',
          <String, String>{'url': url},
        ) ??
        false;
  }
}
