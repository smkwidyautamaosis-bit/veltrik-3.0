import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';
import '../../utils/device_helper.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecureActivationScreen extends StatefulWidget {
  final String reason;
  const SecureActivationScreen({super.key, required this.reason});

  @override
  State<SecureActivationScreen> createState() => _SecureActivationScreenState();
}

class _SecureActivationScreenState extends State<SecureActivationScreen> {
  final _codeController = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;

  void _handleActivate() async {
    if (_codeController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final deviceInfo = await DeviceHelper.getDeviceInfo();

      // Deteksi platform dan gunakan RPC yang sesuai
      if (DeviceHelper.isWebOrIOS) {
        await _service.claimWebAccessCode(
          _codeController.text.trim(),
          deviceInfo['device_id']!,
          deviceInfo['device_name']!,
        );
      } else {
        await _service.claimAccessCode(
          _codeController.text.trim(),
          deviceInfo['device_id']!,
          deviceInfo['device_name']!,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Otorisasi Berhasil!"),
          backgroundColor: Colors.green,
        ),
      );

      // Kembalikan ke Splash Screen agar Gatekeeper mengecek ulang & masuk ke Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.navyBase,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon Security Premium
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: VeltrikColors.cyanAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VeltrikColors.cyanAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 60,
                    color: VeltrikColors.cyanAccent,
                  ),
                ),
                const SizedBox(height: 30),

                Text(
                  "SECURE ACCESS",
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),

                // Menampilkan alasan kenapa diblokir
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    widget.reason,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Form Input Code
                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: VeltrikColors.navyDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ACTIVATION CODE",
                        style: TextStyle(
                          color: VeltrikColors.cyanAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _codeController,
                        style: GoogleFonts.jetBrainsMono(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "Enter 6-8 digit code",
                          hintStyle: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: Colors.black.withValues(alpha: 0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: VeltrikColors.cyanAccent,
                              ),
                            )
                          : SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleActivate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: VeltrikColors.cyanAccent,
                                  foregroundColor: VeltrikColors.navyBase,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "VERIFY & LOCK DEVICE",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                TextButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                  label: const Text(
                    "Logout Account",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
