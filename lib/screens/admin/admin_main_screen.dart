import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants.dart';
import '../../../services/supabase_service.dart';
import '../../../models/material_model.dart';
import '../auth/login_screen.dart';
import 'upload_material_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  final _service = SupabaseService();
  bool _isLoading = false;
  List<dynamic> _transactions = [];
  List<MaterialModel> _materials = [];
  List<dynamic> _users = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      _transactions = await _service.getPendingTransactions();
      _materials = await _service.getMaterials();
      _users = await _service.getAllUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    // FIX: Menggunakan metode bawaan Supabase agar tidak error undefined method
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // Ultra Light Blue Grey
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black12,
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Admin Console",
                style: TextStyle(
                  color: VeltrikColors.navyBase,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const Text(
                "Veltrik Management System",
                style: TextStyle(color: Colors.black38, fontSize: 12),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _loadAllData,
              icon: const Icon(Icons.refresh, color: VeltrikColors.navyBase),
            ),
            IconButton(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: VeltrikColors.cyanAccent,
                ),
              )
            : Column(
                children: [
                  _buildStatsOverview(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TabBar(
                      labelColor: VeltrikColors.navyBase,
                      unselectedLabelColor: Colors.black26,
                      indicatorColor: VeltrikColors.cyanAccent,
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: [
                        Tab(text: "Approval"),
                        Tab(text: "Materials"),
                        Tab(text: "Users"),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildApprovalTab(),
                        _buildMaterialsTab(),
                        _buildUsersTab(),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UploadMaterialScreen()),
            );
            if (result == true) _loadAllData();
          },
          backgroundColor: VeltrikColors.navyBase,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "NEW CONTENT",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatItem(
            "TRX",
            _transactions.length.toString(),
            Icons.receipt_long_rounded,
            Colors.blue,
          ),
          const SizedBox(width: 15),
          _buildStatItem(
            "DOCS",
            _materials.length.toString(),
            Icons.folder_rounded,
            Colors.orange,
          ),
          const SizedBox(width: 15),
          _buildStatItem(
            "USER",
            _users.length.toString(),
            Icons.people_rounded,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), // FIX: withValues
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color.withValues(alpha: 0.7),
              size: 20,
            ), // FIX: withValues
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: VeltrikColors.navyBase,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalTab() {
    if (_transactions.isEmpty) return _buildEmpty("No pending approvals");
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _transactions.length,
      itemBuilder: (ctx, i) {
        final tr = _transactions[i];
        return _buildAdminCard(
          title: tr['profiles']?['username'] ?? 'Anonymous',
          subtitle: "Requesting Premium Access",
          icon: Icons.verified_user_outlined,
          iconColor: Colors.blue,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.black45,
                ),
                onPressed: () => _showProof(tr['proof_path']),
              ),
              IconButton(
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                onPressed: () async {
                  await _service.approveTransaction(tr['id'], tr['user_id']);
                  _loadAllData();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMaterialsTab() {
    if (_materials.isEmpty) return _buildEmpty("No materials uploaded");
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _materials.length,
      itemBuilder: (ctx, i) {
        final m = _materials[i];
        return _buildAdminCard(
          title: m.title,
          subtitle: "Price: Rp ${m.price}",
          icon: Icons.picture_as_pdf_rounded,
          iconColor: Colors.redAccent,
          trailing: IconButton(
            icon: const Icon(
              Icons.delete_sweep_outlined,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              await _service.deleteMaterial(m.id, m.filePath);
              _loadAllData();
            },
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _users.length,
      itemBuilder: (ctx, i) {
        final u = _users[i];
        final isPre = u['is_premium'] ?? false;
        return _buildAdminCard(
          title: u['username'] ?? 'User',
          subtitle: u['role'] == 'admin'
              ? "ADMINISTRATOR"
              : (isPre ? "PREMIUM USER" : "FREE USER"),
          icon: Icons.person_outline_rounded,
          iconColor: u['role'] == 'admin'
              ? Colors.purple
              : (isPre ? VeltrikColors.cyanAccent : Colors.grey),
        );
      },
    );
  }

  Widget _buildAdminCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ), // FIX: withValues
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1), // FIX: withValues
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: VeltrikColors.navyBase,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ],
            ),
          ),
          ?trailing, // FIX: Menggunakan syntax spread null-aware (Dart terbaru)
        ],
      ),
    );
  }

  void _showProof(String path) async {
    final url = await _service.getPaymentProofUrl(path);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Payment Proof",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(url),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(String msg) => Center(
    child: Text(msg, style: const TextStyle(color: Colors.black26)),
  );
}
