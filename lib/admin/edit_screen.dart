import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditBookPage extends StatefulWidget {
  final String idBuku;
  final String judulAwal;
  final String penulisAwal;
  final String gambarSampulAwal;
  final String icon;
  final bool populerAwal;
  final bool direkomendasikanAwal;
  final int ratingAwal; // Add the rating

  const EditBookPage({
    super.key,
    required this.idBuku,
    required this.judulAwal,
    required this.penulisAwal,
    required this.gambarSampulAwal,
    required this.icon,
    required this.populerAwal,
    required this.direkomendasikanAwal,
    required this.ratingAwal, // Add the rating to constructor
  });

  @override
  _HalamanEditBukuState createState() => _HalamanEditBukuState();
}

class _HalamanEditBukuState extends State<EditBookPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulController;
  late TextEditingController _penulisController;
  XFile? _gambarTerpilih;
  bool _populer = false;
  bool _direkomendasikan = false;
  bool _sedangMengunggah = false;
  bool gambarUpdated = false;
  int _rating = 3; // Default rating adalah 3

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: widget.judulAwal);
    _penulisController = TextEditingController(text: widget.penulisAwal);
    _populer = widget.populerAwal;
    _direkomendasikan = widget.direkomendasikanAwal;
    _rating = widget.ratingAwal; // Set the initial rating
  }

  Future<void> _pilihGambar() async {
    final picker = ImagePicker();
    final gambar = await picker.pickImage(source: ImageSource.gallery);
    if (gambar != null) {
      setState(() {
        _gambarTerpilih = gambar;
      });
      setState(() {
        gambarUpdated = true;
      });
    }
  }

  Future<String?> _unggahGambar(XFile gambar) async {
    final storageRef = FirebaseStorage.instance.ref();
    final fileRef =
        storageRef.child('buku/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await fileRef.putFile(File(gambar.path));
    return await fileRef.getDownloadURL();
  }

  Future<void> _perbaruiBuku() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _sedangMengunggah = true;
      });

      try {
        String? urlSampul = widget.icon;
        if (_gambarTerpilih != null) {
          urlSampul = await _unggahGambar(_gambarTerpilih!);
        }

        await FirebaseFirestore.instance
            .collection('buku')
            .doc(widget.idBuku)
            .update({
          'title': _judulController.text,
          'author': _penulisController.text,
          'icon': urlSampul,
          'popular': _populer,
          'recomended': _direkomendasikan,
          'rating': _rating, // Menambahkan rating
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil diperbarui!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Terjadi kesalahan saat memperbarui buku: $e')),
        );
      } finally {
        setState(() {
          _sedangMengunggah = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Buku'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan judul';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _penulisController,
                  decoration: const InputDecoration(labelText: 'Penulis'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan nama penulis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Checkbox(
                      value: _populer,
                      onChanged: (value) {
                        setState(() {
                          _populer = value ?? false;
                        });
                      },
                    ),
                    const Text('Populer'),
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _direkomendasikan,
                      onChanged: (value) {
                        setState(() {
                          _direkomendasikan = value ?? false;
                        });
                      },
                    ),
                    const Text('Direkomendasikan'),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: _rating.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Rating (1-5)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan rating';
                    }
                    final rating = int.tryParse(value);
                    if (rating == null || rating < 1 || rating > 5) {
                      return 'Rating harus antara 1 dan 5';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _rating = int.tryParse(value) ?? 3;
                    });
                  },
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pilihGambar,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _gambarTerpilih != null
                        ? Image.file(
                            File(_gambarTerpilih!.path),
                            fit: BoxFit.cover,
                          )
                        : widget.gambarSampulAwal.isNotEmpty
                            ? Image.network(
                                widget.gambarSampulAwal,
                                fit: BoxFit.cover,
                              )
                            : const Center(child: Text('Pilih Gambar Sampul')),
                  ),
                ),
                const SizedBox(height: 16),
                _sedangMengunggah
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _perbaruiBuku,
                        child: const Text('Simpan'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
