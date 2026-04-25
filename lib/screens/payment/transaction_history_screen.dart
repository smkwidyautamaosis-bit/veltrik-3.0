import 'package:flutter/material.dart';
import '../../core/constants.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: VeltrikColors.navyBase),
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(color: VeltrikColors.navyBase, fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.black.withValues(alpha: 0.1)),
            const SizedBox(height: 20),
            const Text(
              "Belum ada transaksi lainnya.",
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
