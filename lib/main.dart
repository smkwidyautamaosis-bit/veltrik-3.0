import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import package dotenv
import 'core/constants.dart';
import 'screens/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Muat file rahasia .env
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Supabase menggunakan variabel dari .env
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const VeltrikApp());
}

class VeltrikApp extends StatelessWidget {
  const VeltrikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veltrik',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor:
            VeltrikColors.lightBg, // Menggunakan warna terang (Light Mode)
        primaryColor: VeltrikColors.cyanAccent,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: VeltrikColors.navyBase, displayColor: VeltrikColors.navyBase),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withValues(
            alpha: 0.05,
          ), 
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        ),
      ),
      home: const SplashScreen(), // Menampilkan Splash Screen lebih dulu
    );
  }
}
