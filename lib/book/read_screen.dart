import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReadBookPage extends StatelessWidget {
  final String title;
  final String author;

  ReadBookPage({required this.title, required this.author});

  @override
  Widget build(BuildContext context) {
    String pdfFileName = 'books/${title.replaceAll(' ', '_').toLowerCase()}.pdf';


    return Scaffold(
      appBar: AppBar(
        title: Text(title),  // Judul sesuai dengan parameter title
      ),
      body: SfPdfViewer.network('https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf')
    );
  }
}
