import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: VeltrikColors.navyBase,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menggunakan Logo Naga asli dari folder assets
            Image.asset("assets/images/icon.png", height: 120),
            const SizedBox(height: 20),
            Text(
              "Veltrik",
              style: GoogleFonts.exo2(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              "WELCOME!",
              style: TextStyle(
                letterSpacing: 4,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 60),
            _buildBtn(
              context,
              "login",
              Colors.white,
              VeltrikColors.navyBase,
              const LoginScreen(),
            ),
            const SizedBox(height: 15),
            _buildBtn(
              context,
              "Register",
              Colors.white,
              VeltrikColors.navyBase,
              const RegisterScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBtn(
    BuildContext ctx,
    String t,
    Color bg,
    Color clr,
    Widget target,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () =>
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => target)),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            t,
            style: TextStyle(color: clr, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
