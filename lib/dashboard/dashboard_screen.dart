import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:bukuhub/book/read_screen.dart';  // Ganti dengan path yang sesuai

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _currentCarouselIndex = 0;
  late PageController _pageController;
  late PageController _popularBooksController;
  late PageController _recommendedBooksController;
  late Timer _carouselTimer;
  late Timer _popularBooksTimer;
  late Timer _recommendedBooksTimer;
  bool _isExpanded = false;

  final List<String> carouselImages = const [
    'assets/images/carousel/carousel2.png',
    'assets/images/carousel/1.png',
    'assets/images/carousel/2.png',
  ];

  // final List<String> popularBooks = const [
  //   'assets/images/hujan.jpg',
  //   'assets/images/tere_liye.jpg',
  //   'assets/images/ilmu_pengetahuan_sosial.jpg',
  //   'assets/images/book4.jpg',
  //   'assets/images/book5.jpg',
  //   'assets/images/book6.jpg',
  // ];
  List<Map<String, dynamic>> popularBooks = [];

  List<Map<String, dynamic>> recommendedBooks = [];
  // final List<Map<String, dynamic>> recommendedBooks = const [
  //   {
  //     'title': 'Inyik Balang',
  //     'author': 'Andre Septiawan',
  //     'rating': 4.5,
  //     'image': 'assets/images/books/1.jpg',
  //   },
  //   {
  //     'title': 'Detail Kecil',
  //     'author': 'Adania Shibli',
  //     'rating': 4.8,
  //     'image': 'assets/images/books/2.jpg',
  //   },
  //   {
  //     'title': 'Tiga Drama',
  //     'author': 'Seno Gumira Ajidarma',
  //     'rating': 4.8,
  //     'image': 'assets/images/books/3.jpg',
  //   },
  //   {
  //     'title': 'Laut Bercerita',
  //     'author': 'Leila S. Chudori',
  //     'rating': 4.7,
  //     'image': 'assets/images/books/4.png',
  //   },
  //   {
  //     'title': 'Home Sweet Loan',
  //     'author': 'Almira Bastari',
  //     'rating': 4.6,
  //     'image': 'assets/images/books/5.jpg',
  //   },
  //   {
  //     'title': 'Anne of Avonlea',
  //     'author': 'Lucy M. Montgomery',
  //     'rating': 4.7,
  //     'image': 'assets/images/books/6.jpg',
  //   },
  // ];

  // final List<Map<String, String>> categories = [
  //   {'title': 'IPS', 'icon': 'assets/images/icon/history.png'},
  //   {'title': 'IPA', 'icon': 'assets/images/icon/science.png'},
  //   {'title': 'Seni Budaya', 'icon': 'assets/images/icon/art.png'},
  //   {'title': 'Bahasa', 'icon': 'assets/images/icon/languages.png'},
  //   {'title': 'Komik', 'icon': 'assets/images/icon/comic.png'},
  //   {'title': 'Fiksi', 'icon': 'assets/images/icon/fiction.png'},
  //   {'title': 'Non Fiksi', 'icon': 'assets/images/icon/non_fiction.png'},
  //   {'title': 'Agama', 'icon': 'assets/images/icon/religion.png'},
  //   {'title': 'Majalah', 'icon': 'assets/images/icon/magazine.png'},
  // ];
  List<Map<String, String>> categories = [];

  final Map<int, AnimationController> _animationControllers = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchPopularBooks();
    _fetchRecomendedBooks();
    _pageController = PageController();
    _popularBooksController = PageController(
        viewportFraction: 0.3, initialPage: popularBooks.length * 500);
    _recommendedBooksController = PageController(
        viewportFraction: 0.4, initialPage: recommendedBooks.length * 500);

    _carouselTimer = Timer.periodic(const Duration(seconds: 3), _moveCarousel);
    _popularBooksTimer =
        Timer.periodic(const Duration(seconds: 3), _movePopularBooks);
    _recommendedBooksTimer =
        Timer.periodic(const Duration(seconds: 4), _moveRecommendedBooks);

    // for (int i = 0; i < popularBooks.length; i++) {
    //   _animationControllers[i] = AnimationController(
    //     duration: const Duration(milliseconds: 300),
    //     vsync: this,
    //   );
    // }
  }

  Future<void> _fetchCategories() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('kategori_buku').get();
      List<Map<String, String>> loadedCategories = [];

      for (var doc in snapshot.docs) {
        String? iconFileName = doc['icon']; // Nama file icon di Firebase Storage
        String iconUrl = await _getIconUrl(
            'kategori_buku', iconFileName); // Dapatkan URL download

        loadedCategories.add({
          'title': doc['nama'] as String,
          'icon': iconUrl, // Masukkan URL icon yang diunduh
        });
      }
      //  = snapshot.docs.map((doc) {
      //   return {
      //     'title': doc['nama'] as String,
      //     'icon': doc['icon'] as String
      //   };
      // }).toList();

      setState(() {
        categories = loadedCategories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
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
        String? iconFileName = doc['icon']; // Nama file icon di Firebase Storage
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

  Future<void> _fetchRecomendedBooks() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('buku')
          .where('recomended', isEqualTo: true)
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
        recommendedBooks = loadedBooks;
      });
    } catch (e) {
      print('Error fetching books: $e');
    }
  }

  Future<String> _getIconUrl(String dir, String? fileName) async {
    try {
      // Jika fileName null atau kosong, return URL placeholder
      if (fileName == null || fileName.isEmpty) {
        return 'https://placehold.co/150';
      }

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

  void _moveCarousel(Timer timer) {
    if (_currentCarouselIndex < carouselImages.length - 1) {
      _currentCarouselIndex++;
    } else {
      _currentCarouselIndex = 0;
    }
    _pageController.animateToPage(
      _currentCarouselIndex,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _movePopularBooks(Timer timer) {
    _popularBooksController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _moveRecommendedBooks(Timer timer) {
    _recommendedBooksController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(child: LayoutBuilder(builder: (context, constraint) {
        return SingleChildScrollView(
          child: ConstrainedBox(constraints: BoxConstraints(minHeight: constraint.minHeight), child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 10),
              _buildCarousel(),
              _buildSectionHeader('Book Category'),
              const SizedBox(height: 10),
              _buildCategoryList(),
              _buildSectionHeader('Popular Book'),
              _buildPopularBooksList(),
              _buildSectionHeader('Recommended'),
              _buildRecommendedBooksList(),
            ],
          ))
        );
      })),
      bottomNavigationBar: _buildBottomNavigationBar(context, isDarkMode),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'Welcome!',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(width: 5),
              Text(
                'Steven Morison',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            itemCount: carouselImages.length,
            itemBuilder: (context, index) {
              return _buildCarouselItem(carouselImages[index]);
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            carouselImages.length,
            (index) => _buildIndicator(index == _currentCarouselIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(String imagePath) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 16.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );
  }

  Widget _buildCategoryList() {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'No categories available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              _isExpanded
                  ? categories.length
                  : categories.length < 5
                      ? categories.length
                      : 5,
              (index) => _buildCategoryItem(
                categories[index]['title']!,
                categories[index]['icon']!,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildSeeAllButton(),
      ],
    );
  }

  Widget _buildCategoryItem(String title, String imagePath) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.blue,
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }

  Widget _buildSeeAllButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Text(_isExpanded ? 'See Less' : 'See All'),
    );
  }

  Widget _buildPopularBooksList() {
    if (popularBooks.isEmpty) {
      return const Center(
        child: Text(
          'No recomended books available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _recommendedBooksController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final adjustedIndex = index % popularBooks.length;
          final book = popularBooks[adjustedIndex];
          return _buildRecommendedItem(
            book['title'] as String,
            book['author'] as String,
            book['rating'] as int,
            book['icon'] as String,
          );
        },
      ),
    );
  }

  Widget _buildAnimatedBookItem(String imagePath, String title, int index) {
    return GestureDetector(
      onTap: () {
        _animationControllers[index]?.forward().then((_) {
          _animationControllers[index]?.reverse();
        });
      },
      child: ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
          CurvedAnimation(
            parent: _animationControllers[index]!,
            curve: Curves.easeInOut,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 150,
                  width: 100,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Book Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedBooksList() {
    if (recommendedBooks.isEmpty) {
      return const Center(
        child: Text(
          'No recomended books available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: PageView.builder(
        controller: _recommendedBooksController,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final adjustedIndex = index % recommendedBooks.length;
          final book = recommendedBooks[adjustedIndex];
          return _buildRecommendedItem(
            book['title'] as String,
            book['author'] as String,
            book['rating'] as int,
            book['icon'] as String,
          );
        },
      ),
    );
  }

  Widget _buildRecommendedItem(
      String title, String author, int rating, String imagePath) {
    return GestureDetector(
      onTap: () {
        _showBottomSheet(context, title, author, rating);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imagePath,
                fit: BoxFit.cover,
                height: 180,
                width: 120,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 120,
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(author, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('⭐ ${rating.toString()}'),
          ],
        ))
      )
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
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

  void _showBottomSheet(BuildContext context, String title, String author, int rating) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Opsi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.book),
                title: Text('Baca'),
                onTap: () {
                  Navigator.pop(context); // Tutup Bottom Sheet
                  // Tambahkan logika untuk aksi Baca di sini
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadBookPage(title: title, author: author),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Booking'),
                onTap: () {
                  Navigator.pop(context); // Tutup Bottom Sheet
                  // Tambahkan logika untuk aksi Booking di sini
                  print('Booking dipilih untuk $title');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on Home page, no action needed
        break;
      case 1:
        Navigator.pushNamed(context, '/explore');
        break;
      case 2:
        Navigator.pushNamed(context, '/search');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _popularBooksController.dispose();
    _recommendedBooksController.dispose();
    _carouselTimer.cancel();
    _popularBooksTimer.cancel();
    _recommendedBooksTimer.cancel();
    for (var controller in _animationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
