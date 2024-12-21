import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReadBookPage extends StatelessWidget {
  final String title;
  final String author;

  ReadBookPage({required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),  // Judul sesuai dengan parameter title
      ),
      body: SfPdfViewer.asset(
        'books/test.pdf',
        onDocumentLoadFailed: (details) {
          print('Gagal memuat PDF:');
          print(details);
        },
        onDocumentLoaded: (details) {
          print('PDF berhasil dimuat: halaman');
        },
      )
    );
  }
}
