import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Tambahkan ini untuk mendefinisikan File

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _ratingController = TextEditingController();
  bool _isPopular = false;
  bool _isRecommended = false;
  XFile? _selectedImage;
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Buku'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan judul buku';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Pengarang'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan nama pengarang';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Rating (1-5)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan rating';
                  }
                  final rating = int.tryParse(value);
                  if (rating == null || rating < 1 || rating > 5) {
                    return 'Rating harus berupa angka antara 1 hingga 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: _isPopular,
                    onChanged: (value) {
                      setState(() {
                        _isPopular = value ?? false;
                      });
                    },
                  ),
                  const Text('Populer')
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _isRecommended,
                    onChanged: (value) {
                      setState(() {
                        _isRecommended = value ?? false;
                      });
                    },
                  ),
                  const Text('Direkomendasikan')
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                        )
                      : const Center(child: Text('Pilih Gambar Sampul')),
                ),
              ),
              const SizedBox(height: 16),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Simpan'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String> _uploadImage(XFile image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef = storageRef.child('buku/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await fileRef.putFile(File(image.path));
    return await fileRef.getDownloadURL();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text;
      final author = _authorController.text;
      final rating = int.parse(_ratingController.text);

      setState(() {
        _isUploading = true;
      });

      try {
        String? coverImageUrl;
        if (_selectedImage != null) {
          coverImageUrl = await _uploadImage(_selectedImage!);
        }

        // Simpan data ke Firestore
        await FirebaseFirestore.instance.collection('buku').add({
          'title': title,
          'author': author,
          'icon': coverImageUrl,
          'rating': rating,
          'popular': _isPopular,
          'recomended': _isRecommended,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil ditambahkan!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan buku')),
        );
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }
}
