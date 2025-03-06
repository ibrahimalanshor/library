import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  bool isDarkMode = false; // You might want to get this from your theme
  int _selectedIndex = 2; // 2 is the index for Search in bottom navigation

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Function to search books in Firestore
  Future<void> _searchBooks() async {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    try {
      // Query to search books by title
      var querySnapshot = await FirebaseFirestore.instance
          .collection('buku')
          .where('title', isGreaterThanOrEqualTo: _searchController.text)
          .where('title', isLessThanOrEqualTo: _searchController.text + '\uf8ff')
          .get();

      setState(() {
        _searchResults = querySnapshot.docs;
      });
    } catch (e) {
      print('Error searching books: $e');
      // You might want to show a snackbar or error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching books: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildSearchResults(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.blue,
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
              child: TextField(
                controller: _searchController,
                onChanged: (text) {
                  _searchBooks();
                },
                decoration: const InputDecoration(
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

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tidak ada buku ditemukan'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        var book = _searchResults[index];
        String title = book['title'] ?? 'Untitled';
        String icon = book['icon'] ?? '';

        return FutureBuilder<String>(
          future: _getImageUrl(icon),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            String imageUrl = snapshot.data ?? '';
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image, size: 50),
                    )
                  : const Icon(Icons.image, size: 50),
              title: Text(title),
              onTap: () {
                // Handle book selection
              },
            );
          },
        );
      },
    );
  }

  Future<String> _getImageUrl(String iconPath) async {
    if (iconPath.isEmpty) return '';
    
    try {
      final ref = FirebaseStorage.instance.ref().child('buku').child(iconPath);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error getting image URL: $e");
      return '';
    }
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: Colors.blue,
      unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey[600],
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Book Category'),
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
}