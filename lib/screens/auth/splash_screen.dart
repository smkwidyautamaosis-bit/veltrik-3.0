import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../utils/device_helper.dart';
import '../dashboard/dashboard_screen.dart';
import '../admin/admin_main_screen.dart';
import 'welcome_screen.dart';
import 'secure_activation_screen.dart';
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
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminMainScreen()),
          );
          return;
        }

        // --- GATEKEEPER MULTI-PLATFORM ---
        Map<String, dynamic> accessResult;

        if (DeviceHelper.isWebOrIOS) {
          final token = await DeviceHelper.getWebSessionToken();
          accessResult = await _service.verifyWebAccess(token);
        } else {
          final deviceInfo = await DeviceHelper.getDeviceInfo();
          accessResult = await _service.verifyDeviceAccess(
            deviceInfo['device_id']!,
          );
        }

        final isAllowed = accessResult['is_allowed'] == true;
        final reason = accessResult['reason']?.toString() ?? 'Access Denied';

        if (!mounted) return;

        if (isAllowed) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else {
          // Jika Session tertendang oleh device/browser lain (WEB/iOS logic)
          if (reason == 'session_takeover') {
            await Supabase.instance.client.auth.signOut();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Sesi berakhir karena Anda login di perangkat web/iOS lain.",
                ),
                backgroundColor: Colors.orange,
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => SecureActivationScreen(reason: reason),
              ),
            );
          }
        }
      } catch (e) {
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
              "Verifying Secure Environment...",
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
