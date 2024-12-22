import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedIndex = 2; // Starting from the search screen
  final int _currentImageIndex = 0;

  List<Map<String, dynamic>> popularBooks = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchPopularBooks();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(), // Menambahkan warna background biru pada header
              const SizedBox(height: 16),
              _buildRecommendedSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, isDarkMode),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.blue, // Menambahkan background biru
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search your need here...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RECOMMENDED',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const Text(
            'We recommended this book for you.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildRecommendedSlider(),
        ],
      ),
    );
  }

  Widget _buildRecommendedSlider() {
    if (popularBooks.isEmpty) {
      return const Center(
        child: Text(
          'No popular books available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: popularBooks.length,
      options: CarouselOptions(
        autoPlay: true,
        enlargeCenterPage: true,
        aspectRatio: 2.0,
      ),
      itemBuilder: (context, index, realIdx) {
        final book = popularBooks[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Image.network(
                book['icon'],
                fit: BoxFit.cover,
                height: 100,
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(child: Text(
                    truncateWithEllipsis(18, book['title']),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
                  Text(book['rating'].toString(),
                      style: const TextStyle(color: Colors.grey)),
                  const Text(
                    'See Details',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, bool isDarkMode) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey[600],
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.explore), label: 'Book Category'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/explore');
        break;
      case 2:
        // Already on Search page, no action needed
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  Future<void> _fetchPopularBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('buku')
          .where('popular', isEqualTo: true)
          .get();
      List<Map<String, dynamic>> loadedBooks = [];

      for (var doc in snapshot.docs) {
        String iconFileName = doc['icon']; // Nama file icon di Firebase Storage
        String iconUrl =
            await _getIconUrl('buku', iconFileName); // Dapatkan URL download

        loadedBooks.add({
          'title': doc['title'],
          'icon': iconUrl,
          'author': doc['author'],
          'rating': doc['rating'],
        });
      }

      setState(() {
        popularBooks = loadedBooks;

        // _animationControllers
        //     .clear(); // Pastikan controllers kosong sebelum diisi
        // for (int i = 0; i < popularBooks.length; i++) {
        //   _animationControllers[i] = AnimationController(
        //     duration: const Duration(milliseconds: 300),
        //     vsync: this,
        //   );
        // }
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  Future<String> _getIconUrl(String dir, String fileName) async {
    try {
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

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
      ? myString
      : '${myString.substring(0, cutoff)}...';
  }
}
