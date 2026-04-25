import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'hacker_mode_screen.dart';

class DeviceModScreen extends StatelessWidget {
  const DeviceModScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.redAccent),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 100,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 30),
              Text(
                "WARNING:\nUNAUTHORIZED DEVICE MODIFICATION DETECTED",
                textAlign: TextAlign.center,
                style: GoogleFonts.exo2(
                  color: Colors.redAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Proceeding may void your warranty and alter system kernel.",
                textAlign: TextAlign.center,
                style: GoogleFonts.robotoMono(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 50),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HackerModeScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      "START MODIFICATION",
                      style: GoogleFonts.exo2(
                        color: Colors.redAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cancel
                },
                child: const Text(
                  "ABORT SEQUENCE",
                  style: TextStyle(
                    color: Colors.white54,
                    letterSpacing: 1.5,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
