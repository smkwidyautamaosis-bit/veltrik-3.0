import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/constants.dart';
import '../../../services/supabase_service.dart';

class UploadMaterialScreen extends StatefulWidget {
  const UploadMaterialScreen({super.key});

  @override
  State<UploadMaterialScreen> createState() => _UploadMaterialScreenState();
}

class _UploadMaterialScreenState extends State<UploadMaterialScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  File? _selectedFile;
  bool _isLoading = false;
  final _service = SupabaseService();

  // Fungsi pilih file PDF yang stabil di versi 10.x
  void _pickPdf() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memilih file: $e")));
    }
  }

  void _handleUpload() async {
    // Validasi input
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi judul, harga, dan file PDF!")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final price = num.tryParse(_priceController.text.trim()) ?? 0;

      await _service.uploadMaterial(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: price,
        file: _selectedFile!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Materi Veltrik resmi di-publish!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Upload Gagal: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VeltrikColors.navyBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Admin: Upload PDF",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("JUDUL MATERI"),
            _buildTextField(_titleController, "Masukkan judul PDF..."),

            const SizedBox(height: 20),
            _buildLabel("DESKRIPSI"),
            _buildTextField(
              _descController,
              "Apa yang akan user pelajari?",
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            _buildLabel("HARGA (RP)"),
            _buildTextField(_priceController, "Contoh: 50000", isNumber: true),

            const SizedBox(height: 30),

            // UI Pilih File yang Estetik
            InkWell(
              onTap: _pickPdf,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: VeltrikColors.cyanAccent.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 50,
                      color: _selectedFile != null
                          ? VeltrikColors.cyanAccent
                          : Colors.white24,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _selectedFile != null
                          ? _selectedFile!.path.split('/').last
                          : "Ketuk untuk memilih PDF",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _selectedFile != null
                            ? Colors.white
                            : Colors.white38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: VeltrikColors.cyanAccent,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: VeltrikColors.navyBase,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        "PUBLISH SEKARANG",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: VeltrikColors.cyanAccent,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
