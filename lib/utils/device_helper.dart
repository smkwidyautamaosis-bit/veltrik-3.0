import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, String>> getDeviceInfo() async {
    String deviceId = 'unknown_device_id';
    String deviceName = 'Unknown Device';

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // Membuat kombinasi unik dari brand, model, dan ID build Android
        final brand = androidInfo.brand.toString().toUpperCase();
        deviceId = "${androidInfo.brand}-${androidInfo.model}-${androidInfo.id}"
            .replaceAll(' ', '_')
            .toLowerCase();
        deviceName = "$brand ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // iOS memiliki identifierForVendor yang unik per aplikasi
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios_id';
        deviceName = iosInfo.model;
      }
    } catch (e) {
      deviceId = 'fallback_device_id_${DateTime.now().millisecondsSinceEpoch}';
      deviceName = 'Fallback Device';
    }

    return {'device_id': deviceId, 'device_name': deviceName};
  }
}
