import 'package:flutter/material.dart';
import 'splash_screen.dart';
import '../../services/supabase_service.dart';
import '../../utils/device_helper.dart';
import '../../core/constants.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;

  void _handleVerify() async {
    if (_otpController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _service.verifyOtp(widget.email, _otpController.text.trim());

      // Jika menggunakan Web/iOS, paksa generate session token baru untuk takeover session lama
      if (DeviceHelper.isWebOrIOS) {
        final newToken = await DeviceHelper.regenerateWebSessionToken();
        await _service.claimWebSession(newToken);
      }

      if (!mounted) return;

      // Lempar ke SplashScreen untuk memicu Gatekeeper verifikasi security/device
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Verifikasi Gagal: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: VeltrikColors.navyBase),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Verify OTP",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: VeltrikColors.navyBase,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Kode verifikasi telah dikirim ke ${widget.email}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: "Enter 6-digit OTP",
                prefixIcon: Icon(Icons.security),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: VeltrikColors.cyanAccent,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeltrikColors.navyBase,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "VERIFY & CONTINUE",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
