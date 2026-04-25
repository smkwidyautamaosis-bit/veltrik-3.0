import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/constants.dart';

class PdfReaderScreen extends StatelessWidget {
  final String url, title;
  const PdfReaderScreen({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: VeltrikColors.navyBase,
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
