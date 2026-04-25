import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../models/material_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/material_card.dart';
import '../reader/pdf_reader_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState(); // Sudah diperbaiki
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Nama class disamakan
  final _service = SupabaseService();
  List<MaterialModel> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  // Menambahkan Future<void> untuk menghilangkan warning strict_top_level_inference
  Future<void> _fetch() async {
    try {
      final res = await _service.getMaterials();
      setState(() {
        _data = res;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Fetch Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "VELTRIK VAULT",
          style: GoogleFonts.exo2(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VeltrikColors.cyanAccent),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: _data.length,
              itemBuilder: (ctx, i) => MaterialCard(
                material: _data[i],
                onTap: () {
                  final url = _service.getPublicPdfUrl(_data[i].filePath);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PdfReaderScreen(url: url, title: _data[i].title),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: VeltrikColors.navyDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(
            Icons.grid_view_rounded,
            color: VeltrikColors.cyanAccent,
            size: 30,
          ),
          Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white38,
            size: 28,
          ),
          Icon(Icons.person_outline, color: Colors.white38, size: 28),
        ],
      ),
    );
  }
}
