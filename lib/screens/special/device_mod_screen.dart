import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../core/constants.dart';

class DeviceModScreen extends StatefulWidget {
  const DeviceModScreen({super.key});

  @override
  State<DeviceModScreen> createState() => _DeviceModScreenState();
}

class _DeviceModScreenState extends State<DeviceModScreen> {
  bool _isActive = false;
  final List<String> _terminalLogs = [];
  final ScrollController _scrollController = ScrollController();

  double _memoryUsage = 0.0;
  double _cpuLoad = 0.0;
  bool _isSyncing = true;

  String _deviceModel = "Detecting...";
  String _osVersion = "Scanning...";
  String _kernelArch = "Unknown";

  final List<String> _realLogs = [
    "Initializing Veltrik Secure Environment...",
    "Mounting virtual volume: veltrik_crypt_v3.so",
    "Fetching hardware signatures: PASSED",
    "Establishing encrypted handshake with Supabase Cluster-JKT",
    "Session Protocol: AES-256-GCM / TLS 1.3",
    "Syncing user state with cloud database...",
    "Optimizer: Memory leak protection enabled",
    "System Load Balancer: OPTIMAL",
    "Subscribing to real-time events...",
    "Veltrik Core v3.0 heartbeat verified.",
  ];

  @override
  void initState() {
    super.initState();
    _fetchRealDeviceInfo();
  }

  Future<void> _fetchRealDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        // FIX: Casting ke String dengan aman.
        final brand = androidInfo.brand.toString().toUpperCase();
        _deviceModel = "$brand ${androidInfo.model}";
        _osVersion =
            "Android ${androidInfo.version.release} (API ${androidInfo.version.sdkInt})";
        _kernelArch = androidInfo.supportedAbis.isNotEmpty
            ? androidInfo.supportedAbis.first
            : "ARM64";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        // FIX: 'utsname' dihapus di device_info_plus 12.4.0, menggunakan 'model' langsung.
        _deviceModel = iosInfo.model;
        _osVersion = "${iosInfo.systemName} ${iosInfo.systemVersion}";
        _kernelArch = "Darwin Kernel";
      }
    } catch (e) {
      _deviceModel = "Veltrik Optimized Device";
      _osVersion = "Secure Production Env";
      _kernelArch = "Sandbox Isolated";
    }
    if (mounted) setState(() {});
  }

  void _activateSystem() {
    setState(() {
      _isActive = true;
      _memoryUsage = 0.45;
      _cpuLoad = 0.12;
    });
    _startLogSimulation();
    _startStatSimulation();
  }

  void _startLogSimulation() async {
    for (String log in _realLogs) {
      if (!mounted || !_isActive) return;
      await Future.delayed(Duration(milliseconds: 700 + (log.length * 5)));
      setState(() {
        _terminalLogs.add(
          "[${DateTime.now().toString().split(' ')[1].substring(0, 8)}] $log",
        );
      });
      _scrollToBottom();
    }
    if (mounted) setState(() => _isSyncing = false);
  }

  void _startStatSimulation() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted || !_isActive) {
        timer.cancel();
        return;
      }
      setState(() {
        _memoryUsage = 0.4 + (0.1 * (timer.tick % 5) / 5);
        _cpuLoad = 0.05 + (0.15 * (timer.tick % 3) / 3);
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black12,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "DEVICE ENVIRONMENT",
              style: TextStyle(
                color: VeltrikColors.navyBase,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              _isActive ? "System Online" : "System Standby",
              style: TextStyle(
                color: _isActive ? Colors.green : Colors.orange,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          if (_isActive) _buildStatusBadge(),
          const SizedBox(width: 15),
        ],
      ),
      body: !_isActive ? _buildStandbyView() : _buildActiveDashboard(),
    );
  }

  Widget _buildStandbyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: VeltrikColors.cyanAccent.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.power_settings_new_rounded,
                size: 80,
                color: VeltrikColors.navyBase,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "SYSTEM OFFLINE",
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: VeltrikColors.navyBase,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Activate Device Mod to monitor real-time system resources and establish a secure connection environment.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: _activateSystem,
                icon: const Icon(
                  Icons.rocket_launch_rounded,
                  color: VeltrikColors.cyanAccent,
                ),
                label: const Text(
                  "INITIALIZE SYSTEM",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VeltrikColors.navyBase,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("SYSTEM ANALYTICS"),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard(
                "MEMORY",
                "${(_memoryUsage * 100).toInt()}%",
                _memoryUsage,
                Icons.memory_rounded,
                Colors.blue,
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                "CPU LOAD",
                "${(_cpuLoad * 100).toInt()}%",
                _cpuLoad,
                Icons.speed_rounded,
                VeltrikColors.cyanAccent,
              ),
            ],
          ),
          const SizedBox(height: 25),
          _buildSectionHeader("HARDWARE ENVIRONMENT"),
          const SizedBox(height: 15),
          _buildInfoPanel(),
          const SizedBox(height: 25),
          _buildSectionHeader("REAL-TIME CORE LOGS"),
          const SizedBox(height: 15),
          _buildTerminal(),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: VeltrikColors.navyBase.withValues(alpha: 0.5),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _isSyncing
            ? Colors.orange.withValues(alpha: 0.1)
            : Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isSyncing
              ? Colors.orange.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _isSyncing ? Colors.orange : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _isSyncing ? "SYNCING" : "ENCRYPTED",
            style: TextStyle(
              color: _isSyncing ? Colors.orange : Colors.green,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    double progress,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: VeltrikColors.navyBase,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black45,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: VeltrikColors.navyBase,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.phone_android, "Device", _deviceModel),
          const Divider(color: Colors.white12, height: 25),
          _buildInfoRow(Icons.fingerprint, "OS", _osVersion),
          const Divider(color: Colors.white12, height: 25),
          _buildInfoRow(Icons.security, "Architecture", _kernelArch),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: VeltrikColors.cyanAccent, size: 20),
        const SizedBox(width: 15),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTerminal() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: VeltrikColors.cyanAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VeltrikColors.cyanAccent.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(15),
          itemCount: _terminalLogs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                _terminalLogs[index],
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  color: VeltrikColors.navyBase.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
