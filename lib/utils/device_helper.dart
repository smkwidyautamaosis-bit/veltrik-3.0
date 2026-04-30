import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static const String _deviceIdKey = 'veltrik_secure_device_id';
  static const String _webSessionKey = 'veltrik_web_session_token';

  // Deteksi aman untuk Web & iOS
  static bool get isWebOrIOS {
    if (kIsWeb) return true;
    return Platform.isIOS;
  }

  static String _generateSecureId() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(16).toRadixString(16),
    ).join();
  }

  // Mengambil session token Web/iOS
  static Future<String> getWebSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_webSessionKey)) {
      await prefs.setString(_webSessionKey, _generateSecureId());
    }
    return prefs.getString(_webSessionKey)!;
  }

  // Generate ulang token saat login baru (Session Takeover)
  static Future<String> regenerateWebSessionToken() async {
    final prefs = await SharedPreferences.getInstance();
    final newToken = _generateSecureId();
    await prefs.setString(_webSessionKey, newToken);
    return newToken;
  }

  static Future<Map<String, String>> getDeviceInfo() async {
    String deviceId = '';
    String deviceName = 'Unknown Device';

    try {
      if (kIsWeb) {
        final webInfo = await _deviceInfo.webBrowserInfo;
        deviceId = await getWebSessionToken();
        deviceName = "Web Browser (${webInfo.browserName.name})";
        return {'device_id': deviceId, 'device_name': deviceName};
      }

      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceId = await getWebSessionToken();
        deviceName = iosInfo.model;
        return {'device_id': deviceId, 'device_name': deviceName};
      }

      if (Platform.isAndroid) {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey(_deviceIdKey)) {
          deviceId = prefs.getString(_deviceIdKey)!;
        } else {
          deviceId = _generateSecureId();
          await prefs.setString(_deviceIdKey, deviceId);
        }
        final androidInfo = await _deviceInfo.androidInfo;
        final brand = androidInfo.brand.toString().toUpperCase();
        deviceName = "$brand ${androidInfo.model}";
      }
    } catch (e) {
      deviceId = 'fallback_${_generateSecureId()}';
      deviceName = 'Fallback Secure Device';
    }

    return {'device_id': deviceId, 'device_name': deviceName};
  }
}
