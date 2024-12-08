import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../startscreen/start_screen.dart'; // Sesuaikan dengan lokasi StartScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Timer untuk menunggu 4.5 detik sebelum pindah ke StartScreen
    Timer(const Duration(seconds: 4, milliseconds: 500), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const StartScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4285F4), // Warna background biru
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Menggunakan font Oswald untuk teks BukuHub
            const Text(
              'BukuHub',
              style: TextStyle(
                fontFamily: 'SpicyRice', // Pastikan menggunakan font yang benar
                fontSize: 40,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/gif/splash.gif', // Sesuaikan path gambar
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 30),
            // Menggunakan Column untuk teks
            SizedBox(
              width: 250.0,
              child: Column(
                children: [
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Find Your Favorite Book',
                        textStyle: const TextStyle(
                          fontFamily:
                              'QwitcherGrypen', // Gunakan font Qwitcher Grypen
                          fontSize: 27.0,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: const Duration(milliseconds: 500),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                  const SizedBox(height: 5), // Jarak antar baris
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        '& Enjoy It',
                        textStyle: const TextStyle(
                          fontFamily:
                              'QwitcherGrypen', // Gunakan font Qwitcher Grypen
                          fontSize: 27.0,
                          color: Colors.white,
                        ),
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                    pause: const Duration(milliseconds: 500),
                    displayFullTextOnTap: true,
                    stopPauseOnTap: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
