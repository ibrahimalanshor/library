import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;

  const CategoryDetailPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  late Future<List<Map<String, dynamic>>> _booksFuture;

  @override
  void initState() {
    super.initState();
    _booksFuture = fetchBooks();
  }

  Future<List<Map<String, dynamic>>> fetchBooks() async {
    final books = <Map<String, dynamic>>[];

    // Fetch books from Firestore
    final querySnapshot = await FirebaseFirestore.instance
        .collection('buku')
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final coverUrl = await FirebaseStorage.instance
          .ref() // 'icon' is the key pointing to the cover image
          .child('buku')
          .child(data['icon'])
          .getDownloadURL();

      books.add({
        'title': data['title'],
        'coverUrl': coverUrl,
      });
    }

    return books;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada buku.'));
          } else {
            final books = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              itemCount: books.length,
              padding: const EdgeInsets.all(8.0),
              itemBuilder: (context, index) {
                final book = books[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          book['coverUrl'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      book['title'],
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
