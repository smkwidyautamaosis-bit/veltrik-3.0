import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/material_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Helper untuk penanganan error jaringan agar tidak berulang
  void _handleNetworkError(Object e, String defaultMessage) {
    final errorStr = e.toString();
    if (errorStr.contains("SocketException") ||
        errorStr.contains("Failed host lookup") ||
        errorStr.contains("ClientException")) {
      throw Exception("Koneksi Bermasalah. Periksa jaringan Anda.");
    }
    throw Exception("$defaultMessage: $e");
  }

  // ==========================================
  // 1. AUTHENTICATION
  // ==========================================
  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> register(
    String email,
    String password,
    Map<String, dynamic> metadata,
  ) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );
  }

  Future<AuthResponse> verifyOtp(String email, String token) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  Future<void> resendOtp(String email) async {
    await _client.auth.resend(type: OtpType.signup, email: email);
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("Sesi tidak ditemukan.");
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return data;
  }

  // ==========================================
  // 2. MATERIALS & STORAGE
  // ==========================================
  Future<List<MaterialModel>> getMaterials() async {
    try {
      final data = await _client
          .from('materials')
          .select()
          .order('created_at', ascending: false);
      return (data as List).map((e) => MaterialModel.fromJson(e)).toList();
    } catch (e) {
      _handleNetworkError(e, "Gagal memuat materi");
      return []; // Dead code, exception thrown above
    }
  }

  Future<String> createSignedPdfUrl(String filePath) async {
    return await _client.storage
        .from('materials')
        .createSignedUrl(filePath, 3600);
  }

  Future<void> uploadMaterial({
    required String title,
    required String description,
    required num price,
    required File file,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    await _client.storage.from('materials').upload(fileName, file);
    await _client.from('materials').insert({
      'title': title,
      'description': description,
      'price': price,
      'file_path': fileName,
    });
  }

  // ==========================================
  // 3. TRANSACTIONS & ADMIN
  // ==========================================
  Future<void> submitPaymentProof(File proofFile) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception("Sesi habis.");
    final ext = proofFile.path.split('.').last;
    final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
    await _client.storage.from('payments').upload(fileName, proofFile);
    await _client.from('transactions').insert({
      'user_id': user.id,
      'proof_path': fileName,
      'status': 'pending',
    });
  }

  Future<List<dynamic>> getPendingTransactions() async {
    return await _client
        .from('transactions')
        .select('*, profiles(username)')
        .eq('status', 'pending');
  }

  Future<List<dynamic>> getUserTransactions() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception("Sesi tidak ditemukan.");
      return await _client
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
    } catch (e) {
      _handleNetworkError(e, "Gagal memuat transaksi");
      return [];
    }
  }

  Future<String> getPaymentProofUrl(String filePath) async {
    return await _client.storage
        .from('payments')
        .createSignedUrl(filePath, 3600);
  }

  Future<void> approveTransaction(String transactionId, String userId) async {
    await _client.rpc(
      'approve_premium_transaction',
      params: {'t_id': transactionId, 'u_id': userId},
    );
  }

  Future<List<dynamic>> getAllUsers() async {
    return await _client.from('profiles').select();
  }

  Future<void> deleteMaterial(String id, String filePath) async {
    await _client.from('materials').delete().eq('id', id);
    await _client.storage.from('materials').remove([filePath]);
  }

  Future<void> deleteUserAccess(String userId) async {
    await _client.from('profiles').delete().eq('id', userId);
  }
}
