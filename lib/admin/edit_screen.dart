import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBookPage extends StatefulWidget {
  final String bookId;
  final String initialTitle;
  final String initialAuthor;
  final String initialCoverImage;

  const EditBookPage({
    super.key,
    required this.bookId,
    required this.initialTitle,
    required this.initialAuthor,
    required this.initialCoverImage,
  });

  @override
  _EditBookPageState createState() => _EditBookPageState();
}

class _EditBookPageState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _coverImageController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _authorController = TextEditingController(text: widget.initialAuthor);
    _coverImageController = TextEditingController(text: widget.initialCoverImage);
  }

  Future<void> _updateBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseFirestore.instance.collection('books').doc(widget.bookId).update({
          'title': _titleController.text,
          'author': _authorController.text,
          'coverImage': _coverImageController.text,
        });

        // Menampilkan pesan berhasil
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book updated successfully!')));
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } catch (e) {
        // Menampilkan pesan error jika gagal
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating book: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an author';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _coverImageController,
                decoration: const InputDecoration(labelText: 'Cover Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a cover image URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBook,
                child: const Text('Update Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
