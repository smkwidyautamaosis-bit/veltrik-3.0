import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HackerModeScreen extends StatefulWidget {
  const HackerModeScreen({super.key});

  @override
  State<HackerModeScreen> createState() => _HackerModeScreenState();
}

class _HackerModeScreenState extends State<HackerModeScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<String> _logs = [];
  Timer? _logTimer;
  Timer? _exitTimer;
  int _logIndex = 0;

  final List<String> _scriptLines = [
    "[INIT] Booting Veltrik Kernel v2.1.0...",
    "[SYS] Loading core modules...",
    "[SEC] Bypassing encrypted layers at 0x7FFD12...",
    "void main() => runApp(VeltrikApp());",
    "Fetching user credentials...",
    "[DB] Supabase handshake: SUCCESS.",
    "[SYS] Overclocking CPU cores... 14%",
    "[SYS] Overclocking CPU cores... 48%",
    "[SYS] Overclocking CPU cores... 98%",
    "Initializing neural net architecture...",
    "Loading weights from model_v4.bin... DONE",
    "[WARN] Unauthorized access detected from IP: 192.168.1.104",
    "[SEC] Deploying countermeasures...",
    "Connection rerouted to proxy server.",
    "Bypass successful. Root access granted.",
    "Downloading classified files...",
    "10%... 45%... 89%... 100% DONE.",
    "Executing clean_traces.sh...",
    "Logs wiped.",
    "System reboot initiated."
  ];

  @override
  void initState() {
    super.initState();
    // Full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _startHacking();

    // Auto exit after 12 seconds
    _exitTimer = Timer(const Duration(seconds: 12), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  void _startHacking() {
    _logTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) return;
      setState(() {
        if (_logIndex < _scriptLines.length) {
          _logs.add(_scriptLines[_logIndex]);
          _logIndex++;
        } else {
          // Loop random hex
          _logs.add("0x\${(100000 + DateTime.now().millisecondsSinceEpoch % 899999).toRadixString(16).toUpperCase()} DATA_STREAM_ACTIVE");
        }
      });

      // Smooth scroll
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 50,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _logTimer?.cancel();
    _exitTimer?.cancel();
    _scrollController.dispose();
    // Restore status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: _logs.length,
            itemBuilder: (context, index) {
              return Text(
                _logs[index],
                style: GoogleFonts.robotoMono(
                  color: const Color(0xFF00FF00), // Matrix Green
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
