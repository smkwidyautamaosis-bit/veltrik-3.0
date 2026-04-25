import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/material_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // Auth
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

  // Database
  Future<List<MaterialModel>> getMaterials() async {
    final response = await _client.from('materials').select();
    return (response as List).map((m) => MaterialModel.fromMap(m)).toList();
  }

  // Storage
  String getPublicPdfUrl(String path) {
    return _client.storage.from('materi-pdf').getPublicUrl(path);
  }
}
