import 'package:flutter/material.dart';

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
      body: Center(
        child: Text(
          'Konten buku $title oleh $author akan ditampilkan di sini.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
