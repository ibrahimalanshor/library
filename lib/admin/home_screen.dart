import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tambah_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _deleteBook(BuildContext context, String bookId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();
      print('Book deleted successfully!');
    } catch (e) {
      print('Error deleting book: $e');
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, String bookId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Menutup dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteBook(context, bookId); // Hapus buku
                Navigator.of(context).pop(); // Menutup dialog setelah dihapus
              },
              child: const Text('Delete'),
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
        title: const Text('Books List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return const Center(child: Text('Error loading data.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books found.'));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index].data() as Map<String, dynamic>;
              final bookId = books[index].id; // Mendapatkan ID buku
              final title = book['title'] ?? 'Untitled';
              final author = book['author'] ?? 'Unknown Author';
              final coverImage = book['coverImage'] ??
                  'https://via.placeholder.com/150'; // Default placeholder image

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(
                    coverImage,
                    width: 50,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image),
                  ),
                  title: Text(title),
                  subtitle: Text(author),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Aksi edit, bisa ditambahkan nanti
                          print('Edit button pressed for $title');
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
        tooltip: 'Add Book',
      ),
    );
  }
}
