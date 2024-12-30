import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReadBookPage extends StatelessWidget {
  final String title;
  final String author;

  ReadBookPage({required this.title, required this.author});

  Future<String> getPDFUrl(String filePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(filePath);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error getting PDF URL: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    String pdfFilePath = 'buku_pdf/${title.replaceAll(' ', '_').toLowerCase()}.pdf';

    return Scaffold(
      appBar: AppBar(
        title: Text(title), // Judul sesuai dengan parameter title
      ),
      body: FutureBuilder<String>(
        future: getPDFUrl(pdfFilePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(
              child: Text('Failed to load PDF'),
            );
          }

          String pdfUrl = snapshot.data!;
          return SfPdfViewer.network(
            pdfUrl,
            onDocumentLoadFailed: (details) {
              print('Failed to load PDF: ${details.error}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to load PDF')),
              );
            },
          );
        },
      ),
    );
  }
}
