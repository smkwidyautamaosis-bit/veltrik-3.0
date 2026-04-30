import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../utils/device_helper.dart'; // Import Device Helper
import '../dashboard/dashboard_screen.dart';
import '../admin/admin_main_screen.dart';
import 'welcome_screen.dart';
import 'secure_activation_screen.dart'; // Import Secure Activation
import '../../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _service = SupabaseService();

  @override
  void initState() {
    super.initState();
    _checkSessionAndDevice();
  }

  Future<void> _checkSessionAndDevice() async {
    await Future.delayed(const Duration(seconds: 2));
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      try {
        final profile = await _service.getUserProfile();
        final isAdmin = profile['role'] == 'admin';

        if (isAdmin) {
          // Admin bebas dari device lock
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          );
          return;
        }

        // --- GATEKEEPER LOGIC UNTUK USER BIASA ---
        // 1. Ambil Device ID perangkat ini
        final deviceInfo = await DeviceHelper.getDeviceInfo();

        // 2. Verifikasi ke Supabase RPC
        final accessResult = await _service.verifyDeviceAccess(
          deviceInfo['device_id']!,
        );

        final isAllowed = accessResult['is_allowed'] == true;
        final reason = accessResult['reason']?.toString() ?? 'Access Denied';

        if (!mounted) return;

        if (isAllowed) {
          // Device cocok, masa aktif masih ada -> Masuk Dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          // Device tidak cocok / belum aktif / expired -> Masuk Halaman Aktivasi
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SecureActivationScreen(reason: reason),
            ),
          );
        }
      } catch (e) {
        // Jika ada error jaringan atau sesi bermasalah, kembali ke Welcome
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.navyBase,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/icon.png', height: 120),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: VeltrikColors.cyanAccent),
            const SizedBox(height: 20),
            const Text(
              "Verifying Environment...",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
