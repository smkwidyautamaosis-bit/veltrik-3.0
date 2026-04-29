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

  int _selectedIndex = 0;

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
          // FIX: Penanganan type casting Object? secara aman untuk strict Dart
          _role = profile['role']?.toString() ?? 'user';
          _isPremium = profile['is_premium'] == true;
          _username = profile['username']?.toString() ?? 'User';
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

  Widget _buildHistoryOrAdminTab() {
    if (_role == 'admin') return const AdminMainScreen();
    if (_isPremium) return const TransactionHistoryScreen();
    return const UpgradeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.lightBg,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildHistoryOrAdminTab(),
          const DeviceModScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildHomeTab() {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 85,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: [
              Image.asset('assets/images/icon.png', height: 45),
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
                        fontSize: 14,
                        letterSpacing: 2.5,
                      ),
                    ),
                    Text(
                      "Halo, $_username!",
                      style: GoogleFonts.exo2(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
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
          : _buildGridBody(),
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
    );
  }

  Widget _buildGridBody() {
    if (_data.isEmpty) {
      return const Center(
        child: Text("Materi Kosong", style: TextStyle(color: Colors.black54)),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
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
      height: 85,
      padding: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: VeltrikColors.navyDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(Icons.home_rounded, "Beranda", 0),
          _buildNavItem(
            _role == 'admin' ? Icons.fact_check_rounded : Icons.history_rounded,
            _role == 'admin' ? "Admin" : "Riwayat",
            1,
          ),
          _buildNavItem(Icons.terminal_rounded, "System", 2),
          _buildNavItem(Icons.person_rounded, "Profil", 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 0) _initDashboard();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? VeltrikColors.cyanAccent : Colors.white38,
            size: 24,
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
