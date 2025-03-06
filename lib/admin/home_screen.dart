import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'edit_screen.dart';
import 'tambah_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _deleteBook(BuildContext context, String bookId) async {
    try {
      await FirebaseFirestore.instance.collection('buku').doc(bookId).delete();
      print('Buku berhasil dihapus!');
    } catch (e) {
      print('Terjadi kesalahan saat menghapus buku: $e');
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, String bookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Penghapusan'),
          content: const Text('Apakah Anda yakin ingin menghapus buku ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _deleteBook(context, bookId); // Hapus buku
                Navigator.of(context).pop(); // Menutup dialog setelah dihapus
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghapus tombol back
        title: const Text('Daftar Buku'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('buku').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(
                child: Text('Terjadi kesalahan saat memuat data.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada buku yang ditemukan.'));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index].data() as Map<String, dynamic>;
              final bookId = books[index].id; // Mendapatkan ID buku
              final title = book['title'] ?? 'Tanpa Judul';
              final author = book['author'] ?? 'Penulis Tidak Diketahui';
              final populer = book['popular'] ?? false;
              final direkomendasikan = book['recomended'] ?? false;
              final rating = book['rating'] ?? 0.0;
              final icon = book['icon'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: FutureBuilder<String>(
                  future: _getIconUrl('buku', book['icon']),
                  builder: (context, snapshot) {
                    final coverImage = snapshot.data ??
                        ''; // Default to an empty string if the future is still loading or fails
                    return ListTile(
                      leading: snapshot.connectionState == ConnectionState.done
                          ? Image.network(
                              coverImage,
                              width: 50,
                              height: 75,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image),
                            )
                          : const SizedBox(
                              width: 50,
                              height: 75,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                      title: Text(title),
                      subtitle: Text(author),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBookPage(
                                    idBuku: bookId, // Kirim ID buku
                                    judulAwal: title, // Kirim data judul
                                    penulisAwal: author, // Kirim data penulis
                                    gambarSampulAwal:
                                        coverImage, // Kirim URL cover image
                                    icon: icon,
                                    populerAwal: populer is bool
                                        ? populer
                                        : populer.toString().toLowerCase() ==
                                            'true', // Kirim status populer
                                    direkomendasikanAwal: direkomendasikan
                                            is bool
                                        ? direkomendasikan
                                        : direkomendasikan
                                                .toString()
                                                .toLowerCase() ==
                                            'true', // Kirim status direkomendasikan
                                    ratingAwal: rating, // Kirim rating buku
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _showDeleteConfirmation(context, bookId);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBookPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Buku',
      ),
    );
  }

  Future<String> _getIconUrl(String dir, String? fileName) async {
    try {
      // Jika fileName null atau kosong, return URL placeholder
      if (fileName == null || fileName.isEmpty) {
        return 'https://placehold.co/150';
      }

      // Mendapatkan URL dari Firebase Storage berdasarkan nama file
      String downloadUrl = await FirebaseStorage.instance
          .ref()
          .child(dir)
          .child(fileName)
          .getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error fetching icon from Firebase Storage: $e');
      return '';
    }
  }
}
