import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController(), _pass = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.lightBg,
      body: Stack(
        children: [
          // Bagian Logo Atas
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Image.network(
                "https://i.ibb.co/3mYmGjH/veltrik-logo.png",
                height: 150,
              ), // Ganti dengan logo naga kamu
            ),
          ),
          // Sheet Navy Melengkung
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: const BoxDecoration(
                color: VeltrikColors.navyBase,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              padding: const EdgeInsets.all(40),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _field("Email", _email, Icons.person),
                    const SizedBox(height: 15),
                    _field("Password", _pass, Icons.lock, obs: true),
                    const SizedBox(height: 40),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _loginBtn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String hint,
    TextEditingController ctr,
    IconData icon, {
    bool obs = false,
  }) {
    return TextField(
      controller: ctr,
      obscureText: obs,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.white60),
      ),
    );
  }

  Widget _loginBtn() {
    return SizedBox(
      width: 120,
      child: ElevatedButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            await SupabaseService().login(
              _email.text.trim(),
              _pass.text.trim(),
            );
            if (mounted)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
                (r) => false,
              );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("$e")));
          } finally {
            setState(() => _isLoading = false);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          "Log In",
          style: TextStyle(color: VeltrikColors.navyBase),
        ),
      ),
    );
  }
}
