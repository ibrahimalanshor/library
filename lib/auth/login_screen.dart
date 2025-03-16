import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Login ke Firebase
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Ambil ID token dengan klaim terbaru
        final idTokenResult = await user.getIdTokenResult(true);
        final isAdmin = idTokenResult.claims?['admin'] ?? false; // Cek klaim admin

        // Redirect ke halaman yang sesuai
        if (isAdmin) {
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      }
    } on FirebaseAuthException catch (e) {
      // Tangani error login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Login failed')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/login.png', width: 100, height: 100),
              const SizedBox(height: 20),
              const Text(
                'BukuHub',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Text('LIBRARY APP', style: TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration(Icons.email, 'Email or Phone'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration(Icons.lock, 'Password'),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: Colors.white)),
              ),
              const SizedBox(height: 20),
              _buildButton('Login', _login),
              const SizedBox(height: 16),
              const Text('Or', style: TextStyle(fontSize: 16, color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              _buildButton('Create an Account', () {}),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(IconData icon, String hintText) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      border: InputBorder.none,
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))
            : Text(text, style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
