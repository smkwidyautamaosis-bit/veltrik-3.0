import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../services/supabase_service.dart';
import '../../../models/material_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: VeltrikColors.navyBase,
        appBar: AppBar(
          backgroundColor: VeltrikColors.navyDark,
          title: const Text(
            "Veltrik Control Center",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            indicatorColor: VeltrikColors.cyanAccent,
            labelColor: VeltrikColors.cyanAccent,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.receipt_long), text: "Transaksi"),
              Tab(icon: Icon(Icons.folder_special), text: "Storage"),
              Tab(icon: Icon(Icons.people), text: "Users"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: VeltrikColors.cyanAccent,
                ),
              )
            : TabBarView(
                children: [
                  _buildTabTransaksi(),
                  _buildTabStorage(),
                  _buildTabUsers(),
                ],
              ),
      ),
    );
  }

  Widget _buildTabTransaksi() {
    if (_transactions.isEmpty)
      return const Center(
        child: Text(
          "Tidak ada transaksi pending.",
          style: TextStyle(color: Colors.white24),
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _transactions.length,
      itemBuilder: (ctx, i) {
        final tr = _transactions[i];
        final username = tr['profiles'] != null
            ? tr['profiles']['username']
            : 'Unknown';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.orangeAccent,
              child: Icon(Icons.payment, color: Colors.white),
            ),
            title: Text(
              username,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.image, color: Colors.blueAccent),
                  onPressed: () async {
                    final url = await _service.getPaymentProofUrl(
                      tr['proof_path'],
                    );
                    if (!mounted) return;
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: VeltrikColors.navyDark,
                        content: Image.network(url),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("TUTUP"),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                  ),
                  onPressed: () async {
                    await _service.approveTransaction(tr['id'], tr['user_id']);
                    _loadAllData();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabStorage() {
    if (_materials.isEmpty)
      return const Center(
        child: Text("Storage Kosong", style: TextStyle(color: Colors.white24)),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _materials.length,
      itemBuilder: (ctx, i) {
        final m = _materials[i];
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
          title: Text(m.title, style: const TextStyle(color: Colors.white)),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.white38),
            onPressed: () async {
              await _service.deleteMaterial(m.id, m.filePath);
              _loadAllData();
            },
          ),
        );
      },
    );
  }

  Widget _buildTabUsers() {
    if (_users.isEmpty)
      return const Center(
        child: Text("User Kosong", style: TextStyle(color: Colors.white24)),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _users.length,
      itemBuilder: (ctx, i) {
        final u = _users[i];
        final isPre = u['is_premium'] ?? false;
        return ListTile(
          leading: Icon(
            Icons.person,
            color: isPre ? VeltrikColors.cyanAccent : Colors.white24,
          ),
          title: Text(
            u['username'] ?? 'No Name',
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            u['role'] == 'admin' ? "ADMIN" : (isPre ? "PREMIUM" : "FREE"),
            style: const TextStyle(color: Colors.white24, fontSize: 10),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.person_remove, color: Colors.redAccent),
            onPressed: () async {
              await _service.deleteUserAccess(u['id']);
              _loadAllData();
            },
          ),
        );
      },
    );
  }
}
