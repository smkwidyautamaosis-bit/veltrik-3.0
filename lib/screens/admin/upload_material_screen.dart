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
        backgroundColor: VeltrikColors.navyDark,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Form Upload Materi",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Panel Form
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: VeltrikColors.navyDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Dokumen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("JUDUL MATERI"),
                  _buildTextField(
                    _titleController,
                    "Misal: Modul Flutter Advanced",
                    Icons.title,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("DESKRIPSI"),
                  _buildTextField(
                    _descController,
                    "Jelaskan isi materi secara singkat...",
                    Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),

                  _buildLabel("HARGA MATERI (RP)"),
                  _buildTextField(
                    _priceController,
                    "0 untuk gratis, misal: 50000",
                    Icons.monetization_on,
                    isNumber: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Panel Upload
            const Text(
              "File Dokumen (PDF)",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            InkWell(
              onTap: _pickPdf,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: _selectedFile != null
                      ? VeltrikColors.cyanAccent.withValues(alpha: 0.1)
                      : VeltrikColors.navyDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedFile != null
                        ? VeltrikColors.cyanAccent
                        : Colors.white24,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.task_alt
                          : Icons.cloud_upload_rounded,
                      size: 60,
                      color: _selectedFile != null
                          ? VeltrikColors.cyanAccent
                          : Colors.white38,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      _selectedFile != null
                          ? "File Terpilih:"
                          : "Tarik & Lepas File atau Ketuk Disini",
                      style: TextStyle(
                        color: _selectedFile != null
                            ? VeltrikColors.cyanAccent
                            : Colors.white54,
                      ),
                    ),
                    if (_selectedFile != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        _selectedFile!.path.split('/').last,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Tombol Publish
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: VeltrikColors.cyanAccent,
                    ),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _handleUpload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: VeltrikColors.cyanAccent,
                        foregroundColor: VeltrikColors.navyBase,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.publish, size: 24),
                      label: const Text(
                        "PUBLISH MATERI",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
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
    String hint,
    IconData icon, {
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
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.white54) : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: VeltrikColors.cyanAccent),
        ),
      ),
    );
  }
}
