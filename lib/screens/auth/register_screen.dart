import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import 'verify_otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;

  void _register() async {
    setState(() => _isLoading = true);
    try {
      await _service.register(_emailController.text, _passwordController.text, {
        'username': _usernameController.text,
        'role': 'user',
        'is_premium': false,
        'phone': _phoneController.text,
      });
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(email: _emailController.text),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Daftar Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6ECF5),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Center(
              // Path gambar sudah diperbaiki
              child: Image.asset(
                'assets/images/icon.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.local_fire_department,
                  size: 80,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 8,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              decoration: const BoxDecoration(
                color: Color(0xFF1B2A49),
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5, bottom: 25),
                      height: 2,
                      width: 60,
                      color: Colors.white,
                    ),

                    _buildPillTextField(
                      controller: _usernameController,
                      icon: Icons.person,
                      hint: "Username",
                    ),
                    const SizedBox(height: 15),
                    _buildPillTextField(
                      controller: _emailController,
                      icon: Icons.email,
                      hint: "Email",
                    ),
                    const SizedBox(height: 15),
                    _buildPillTextField(
                      controller: _passwordController,
                      icon: Icons.lock,
                      hint: "Password",
                      isObscure: true,
                    ),
                    const SizedBox(height: 15),
                    _buildPillTextField(
                      controller: _phoneController,
                      icon: Icons.phone_android,
                      hint: "Phone",
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : SizedBox(
                              width: 150,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1B2A49),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool isObscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Color(0xFF1B2A49)),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}
