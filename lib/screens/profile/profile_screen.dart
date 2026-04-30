import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../services/supabase_service.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _service = SupabaseService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await _service.getUserProfile();
      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "MY PROFILE",
          style: TextStyle(
            color: VeltrikColors.navyBase,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: VeltrikColors.cyanAccent),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildAccessInfoCard(), // New Expiry Info Card
                  const SizedBox(height: 25),
                  _buildMenuSection(),
                  const SizedBox(height: 40),
                  _buildLogoutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: VeltrikColors.navyBase,
          child: Text(
            (_profile?['username'] ?? "U").substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: VeltrikColors.cyanAccent,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(
          _profile?['username'] ?? "Veltrik User",
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: VeltrikColors.navyBase,
          ),
        ),
        Text(
          _profile?['email'] ?? "",
          style: const TextStyle(color: Colors.black38, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildAccessInfoCard() {
    final subType = _profile?['subscription_type'] ?? 'Free Account';
    final expiryStr = _profile?['access_expires_at'];
    final isLifetime = subType == 'unlimited';

    DateTime? expiryDate;
    if (expiryStr != null) expiryDate = DateTime.parse(expiryStr).toLocal();

    String statusText = "Active";
    Color statusColor = Colors.green;
    String timeRemaining = "";

    if (!isLifetime && expiryDate != null) {
      final now = DateTime.now();
      final difference = expiryDate.difference(now);

      if (difference.isNegative) {
        statusText = "Expired";
        statusColor = Colors.redAccent;
        timeRemaining = "Masa aktif habis";
      } else if (difference.inDays < 7) {
        statusText = "Expiring Soon";
        statusColor = Colors.orange;
        timeRemaining = "${difference.inDays} hari tersisa";
      } else {
        timeRemaining = "${difference.inDays} hari tersisa";
      }
    } else if (isLifetime) {
      timeRemaining = "Akses Seumur Hidup";
    } else {
      statusText = "Inactive";
      statusColor = Colors.grey;
      timeRemaining = "Belum Diaktivasi";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "SYSTEM ACCESS",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                  letterSpacing: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            subType.replaceAll('_', ' ').toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: VeltrikColors.navyBase,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            timeRemaining,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!isLifetime && expiryDate != null) ...[
            const Divider(height: 30),
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 16,
                  color: Colors.black38,
                ),
                const SizedBox(width: 8),
                Text(
                  "Berakhir pada: ${expiryDate.day}/${expiryDate.month}/${expiryDate.year}",
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          Icons.devices_other_rounded,
          "Linked Device",
          _profile?['linked_device_name'] ?? "Not Set",
        ),
        _buildMenuItem(
          Icons.security_update_good_rounded,
          "Security Status",
          "Encrypted",
        ),
        _buildMenuItem(Icons.help_outline_rounded, "Bantuan", "Hubungi Admin"),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Icon(icon, color: VeltrikColors.navyBase, size: 20),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: VeltrikColors.navyBase,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.black38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () async {
          await _service.logout();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
        label: const Text(
          "SIGN OUT",
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
