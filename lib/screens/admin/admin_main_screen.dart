import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
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
        backgroundColor: const Color(0xFFF8FAFC),
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
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color.withValues(alpha: 0.7), size: 20),
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
    if (_transactions.isEmpty) {
      return _buildEmpty("No pending approvals");
    }
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
    if (_materials.isEmpty) {
      return _buildEmpty("No materials uploaded");
    }
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
        final isAdmin = u['role'] == 'admin';
        final status = u['status'] ?? 'pending';
        final deviceName = u['linked_device_name'] ?? 'No Device Linked';

        Color statusColor = Colors.grey;
        if (status == 'active') statusColor = Colors.green;
        if (status == 'suspended') statusColor = Colors.redAccent;
        if (isAdmin) statusColor = Colors.purple;

        return _buildAdminCard(
          title: u['username'] ?? 'User',
          subtitle: isAdmin
              ? "ADMINISTRATOR"
              : "Status: ${status.toUpperCase()} • $deviceName",
          icon: Icons.person_outline_rounded,
          iconColor: statusColor,
          trailing: isAdmin
              ? null
              : ElevatedButton(
                  onPressed: () => _showUserManagementModal(u),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: VeltrikColors.navyBase.withValues(
                      alpha: 0.05,
                    ),
                    foregroundColor: VeltrikColors.navyBase,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  child: const Text(
                    "Manage",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
        );
      },
    );
  }

  void _showUserManagementModal(Map<String, dynamic> user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 25,
            right: 25,
            top: 25,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Manage Access: ${user['username']}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: VeltrikColors.navyBase,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "ID: ${user['id']}",
                style: const TextStyle(fontSize: 10, color: Colors.black38),
              ),
              const Divider(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Linked Device:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    user['linked_device_name'] ?? "None",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: VeltrikColors.navyBase,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Device Reset Count:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    (user['device_reset_count'] ?? 0).toString(),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (user['access_code'] != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pending Code: ${user['access_code']}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy,
                          size: 16,
                          color: Colors.orange,
                        ),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: user['access_code']),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Code copied!")),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 30),

              const Text(
                "ADMIN ACTIONS",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),

              _buildModalAction(
                Icons.vpn_key_rounded,
                "Generate Access Code",
                VeltrikColors.cyanAccent,
                () {
                  Navigator.pop(context);
                  _showGenerateCodeDialog(user['id']);
                },
              ),

              _buildModalAction(
                Icons.phonelink_erase_rounded,
                "Reset Linked Device",
                Colors.orange,
                () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  await _service.adminResetDevice(user['id']);
                  _loadAllData();
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Device di-reset!")),
                    );
                },
              ),

              _buildModalAction(
                Icons.block_flipped,
                "Suspend & Revoke Access",
                Colors.redAccent,
                () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  await _service.revokeUserAccess(user['id']);
                  _loadAllData();
                  if (mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Akses dicabut!")),
                    );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showGenerateCodeDialog(String userId) {
    String selectedDuration = '30_days';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (contextDialog, setStateSB) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Generate Code",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: VeltrikColors.navyBase,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Pilih masa aktif akses untuk user ini:",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 15),
                // Fix Deprecated member warning: menggunakan InputDecoration dengan DropdownButton murni
                InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedDuration,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: '7_days',
                          child: Text("7 Hari"),
                        ),
                        DropdownMenuItem(
                          value: '30_days',
                          child: Text("30 Hari (1 Bulan)"),
                        ),
                        DropdownMenuItem(
                          value: '90_days',
                          child: Text("90 Hari (3 Bulan)"),
                        ),
                        DropdownMenuItem(
                          value: 'unlimited',
                          child: Text("Unlimited / Lifetime"),
                        ),
                      ],
                      onChanged: (val) =>
                          setStateSB(() => selectedDuration = val!),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  "CANCEL",
                  style: TextStyle(color: Colors.black38),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  final code = await _service.generateUserAccessCode(
                    userId,
                    selectedDuration,
                  );
                  await _loadAllData();

                  // Fix use_build_context_synchronously warning
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: VeltrikColors.navyDark,
                      title: const Text(
                        "Code Generated!",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: VeltrikColors.cyanAccent,
                          letterSpacing: 5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: code));
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Kode disalin ke clipboard!"),
                              ),
                            );
                          },
                          child: const Text(
                            "COPY & CLOSE",
                            style: TextStyle(color: VeltrikColors.cyanAccent),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeltrikColors.navyBase,
                  foregroundColor: Colors.white,
                ),
                child: const Text("GENERATE"),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModalAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
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
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
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
          // Fix null-aware marker warning (sebelumnya: if (trailing != null) trailing)
          ?trailing,
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
