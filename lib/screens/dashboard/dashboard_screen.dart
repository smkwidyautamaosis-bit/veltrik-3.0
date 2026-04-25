import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../models/material_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/material_card.dart';
import '../reader/pdf_reader_screen.dart';

import '../admin/upload_material_screen.dart';
import '../payment/upgrade_screen.dart';
import '../payment/transaction_history_screen.dart';
import '../admin/admin_main_screen.dart';
import '../profile/profile_screen.dart';
import '../special/device_mod_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _service = SupabaseService();
  final _client = Supabase.instance.client;
  List<MaterialModel> _data = [];
  bool _isLoading = true;
  String _role = 'user';
  bool _isPremium = false;
  String _username = 'User';

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return;

      final profile = await _service.getUserProfile();
      final materials = await _service.getMaterials();

      if (mounted) {
        setState(() {
          _role = profile['role'] ?? 'user';
          _isPremium = profile['is_premium'] ?? false;
          _username = profile['username'] ?? 'User';
          _data = materials;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Image.asset('assets/images/icon.png', height: 55),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VELTRIK",
                      style: TextStyle(
                        color: VeltrikColors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      "Halo, $_username!",
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: VeltrikColors.navyBase,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VeltrikColors.cyanAccent),
            )
          : _buildBody(),
      floatingActionButton: _role == 'admin'
          ? FloatingActionButton(
              backgroundColor: VeltrikColors.cyanAccent,
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadMaterialScreen(),
                  ),
                );
                if (res == true) _initDashboard();
              },
              child: const Icon(Icons.add, color: VeltrikColors.navyBase),
            )
          : null,
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildBody() {
    if (_data.isEmpty) {
      return const Center(
        child: Text("Materi Kosong", style: TextStyle(color: Colors.black54)),
      );
    }
    return GridView.builder(
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
        onTap: () async {
          if (!_isPremium && _role != 'admin') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Akses Premium Ditolak!")),
            );
            return;
          }
          final url = await _service.createSignedPdfUrl(_data[i].filePath);
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PdfReaderScreen(url: url, title: _data[i].title),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        color: VeltrikColors.navyDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(Icons.home_rounded, "Beranda", true, () {}),
          _buildNavItem(
            _role == 'admin' ? Icons.fact_check_rounded : Icons.history_rounded,
            _role == 'admin' ? "Admin" : "Riwayat",
            false,
            () {
              if (_role == 'admin') {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMainScreen())).then((_) => _initDashboard());
              } else if (_isPremium) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const UpgradeScreen()));
              }
            },
          ),
          _buildNavItem(Icons.terminal_rounded, "Device Mod", false, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DeviceModScreen()));
          }),
          _buildNavItem(Icons.person_rounded, "Profil", false, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())).then((_) => _initDashboard());
          }),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? VeltrikColors.cyanAccent : Colors.white38,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? VeltrikColors.cyanAccent : Colors.white38,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
