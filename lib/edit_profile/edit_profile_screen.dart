import 'dart:io'; // Untuk menggunakan File (untuk image)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Untuk memilih gambar
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mengakses Firebase Auth
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'dart:typed_data'; // Untuk mengkonversi gambar ke bytes

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  File? _imageFile; // For storing the selected image file
  bool _isLoading = false; // Variabel untuk mengontrol status loading
  Uint8List? _imageBytes; // Untuk menyimpan bytes gambar

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imageFile = File(image.path); // Update the image file state
      });

      final bytes = await image.readAsBytes(); // Membaca gambar menjadi bytes
      setState(() {
        _imageBytes = bytes; // Update dengan bytes gambar
      });
    }
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      _nameController.text = user.displayName ?? '';
    }
  }

  void _handleUpdate() async {
    setState(() {
      _isLoading = true; // Set loading true saat mulai update
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? photoUrl = _imageBytes != null ? await _uploadImageToStorage() : user.photoURL;

        await user.updateDisplayName(_nameController.text); // Update nama
        // Update photo URL jika ada image baru
        if (photoUrl != null) {
          await user.updatePhotoURL(photoUrl);
        }

        await user.reload(); // Reload user untuk mendapatkan data terbaru
        user = FirebaseAuth.instance.currentUser; // Refresh user data

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading false setelah update selesai
      });
    }
  }

  // Fungsi untuk upload image ke Firebase Storage
  Future<String?> _uploadImageToStorage() async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_pictures/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageRef.putData(_imageBytes!); // Meng-upload image bytes
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Image Error: $e')));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageBytes != null
                        ? MemoryImage(_imageBytes!)
                        : const AssetImage('/images/placeholder/user.png') as ImageProvider,
                    child: const Icon(Icons.camera_alt,
                    color: Colors.white), // Icon for picking image
                  ),
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField("Display Name", controller: _nameController),
              
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                    ? null // Nonaktifkan tombol saat loading
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _handleUpdate(); // Menangani update saat tombol diklik
                        }
                      }, // Disable button while loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText,
      {bool isPassword = false, onChanged, required TextEditingController controller}) {
    return TextField(
      controller: controller, // Pasangkan controller ke TextField
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      onChanged: onChanged,
    );
  }
}
