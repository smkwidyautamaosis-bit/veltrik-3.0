import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _user = TextEditingController(),
      _email = TextEditingController(),
      _pass = TextEditingController(),
      _phone = TextEditingController();
  final _service = SupabaseService();
  bool _isLoading = false;

  void _handleReg() async {
    setState(() => _isLoading = true);
    try {
      await _service.register(_email.text.trim(), _pass.text.trim(), {
        'username': _user.text.trim(),
        'phone': _phone.text.trim(),
      });

      // PERBAIKAN: Cek mounted sebelum menggunakan BuildContext setelah await
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Registrasi Berhasil!")));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              const Text(
                "New Identity",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _user,
                decoration: const InputDecoration(hintText: "Username"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _email,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Password"),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _phone,
                decoration: const InputDecoration(hintText: "Phone"),
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleReg,
                      child: const Text("CREATE ACCOUNT"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
