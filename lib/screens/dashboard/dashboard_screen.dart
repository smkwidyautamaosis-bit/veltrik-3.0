import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../models/material_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/material_card.dart';
import '../reader/pdf_reader_screen.dart';
import '../auth/login_screen.dart';
import '../admin/upload_material_screen.dart';
import '../payment/upgrade_screen.dart';
import '../admin/admin_main_screen.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, $_username!",
              style: GoogleFonts.exo2(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              _role == 'admin'
                  ? "Admin Panel"
                  : (_isPremium ? "Premium Member" : "Free User"),
              style: TextStyle(
                fontSize: 12,
                color: _role == 'admin'
                    ? Colors.redAccent
                    : VeltrikColors.cyanAccent,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await _client.auth.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
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
    if (_data.isEmpty)
      return const Center(
        child: Text("Materi Kosong", style: TextStyle(color: Colors.white24)),
      );
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
      decoration: const BoxDecoration(
        color: VeltrikColors.navyDark,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(
            Icons.grid_view_rounded,
            color: VeltrikColors.cyanAccent,
            size: 30,
          ),
          IconButton(
            icon: Icon(
              _role == 'admin'
                  ? Icons.fact_check_outlined
                  : Icons.receipt_long_outlined,
              color: Colors.white38,
              size: 28,
            ),
            onPressed: () {
              if (_role == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminMainScreen()),
                ).then((_) => _initDashboard());
              } else if (!_isPremium) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                );
              }
            },
          ),
          const Icon(Icons.person_outline, color: Colors.white38, size: 28),
        ],
      ),
    );
  }
}
