import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({Key? key}) : super(key: key);

  Future<String> _getImageUrl(String fileName) async {
    // Path lengkap di Firebase Storage
    final ref = FirebaseStorage.instance.ref('buku/$fileName');
    return await ref.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    final Query booksRef =
        FirebaseFirestore.instance.collection('booking')
          .where('userId', isEqualTo: userId); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Booking Buku'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: booksRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            // Mendapatkan data buku dari Firestore
            final books = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'id': doc.id,
                'title': data['title'],
                'cover': data['icon'], // Nama file di Storage
              };
            }).toList();

            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return Column(
                  children: [
                    FutureBuilder(
                      future: _getImageUrl(book['cover']),
                      builder: (context, AsyncSnapshot<String> imageSnapshot) {
                        if (imageSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            leading: CircularProgressIndicator(),
                            title: Text('Loading...'),
                          );
                        }

                        if (imageSnapshot.hasError) {
                          return ListTile(
                            leading: const Icon(Icons.error),
                            title: Text(book['title']),
                            subtitle: Text('Gagal membuat daftar booking'),
                          );
                        }

                        return ListTile(
                          leading: Image.network(
                            imageSnapshot.data!,
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                          title: Text(book['title']),
                          onTap: () {
                            // Tambahkan aksi ketika item diklik
                            // ScaffoldMessenger.of(context).showSnackBar(
                            //   SnackBar(content: Text('Tapped on ${book['title']}')),
                            // );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                  ]
                );
              },
            );
          }

          return const Center(child: Text('Belum ada booking'));
        },
      ),
    );
  }
}
