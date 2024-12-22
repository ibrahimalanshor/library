import 'package:flutter/material.dart';

class BookCategoryPage extends StatefulWidget {
  const BookCategoryPage({super.key});

  @override
  _BookCategoryPageState createState() => _BookCategoryPageState();
}

class _BookCategoryPageState extends State<BookCategoryPage> {
  int _selectedIndex = 1;
  String _selectedKelas = 'All';
  String _selectedTahunTerbit = 'All';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 1:
        // Already on Book Category page, no action needed
        break;
      case 2:
        Navigator.pushNamed(context, '/search');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _showFilterModal(BuildContext context, bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]
                : Colors.blue[300], // Background biru/dark mode
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              const Text('Kelas', style: TextStyle(color: Colors.white)),
              Wrap(
                spacing: 10,
                children: ['X', 'XI', 'XII']
                    .map((kelas) => ChoiceChip(
                          label: Text(kelas),
                          labelStyle: TextStyle(
                            color: _selectedKelas == kelas
                                ? Colors.blue
                                : Colors.white,
                          ),
                          selected: _selectedKelas == kelas,
                          selectedColor: Colors.white, // Warna tombol aktif
                          backgroundColor: Colors.blue, // Warna tombol default
                          onSelected: (selected) {
                            setState(() {
                              _selectedKelas = selected ? kelas : 'All';
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              const Text('Tahun Terbit', style: TextStyle(color: Colors.white)),
              Wrap(
                spacing: 10,
                children: ['Terbaru', '5 Tahun Terakhir', 'Lainnya']
                    .map((tahun) => ChoiceChip(
                          label: Text(tahun),
                          labelStyle: TextStyle(
                            color: _selectedTahunTerbit == tahun
                                ? Colors.blue
                                : Colors.white,
                          ),
                          selected: _selectedTahunTerbit == tahun,
                          selectedColor: Colors.white,
                          backgroundColor: Colors.blue,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTahunTerbit = selected ? tahun : 'All';
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // Warna tombol
                    foregroundColor: Colors.blue, // Warna teks pada tombol
                  ),
                  onPressed: () {
                    // Apply filter logic here
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filter'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDarkMode),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterButtons(isDarkMode),
                      const SizedBox(height: 20),
                      _buildCategoryGrid(isDarkMode),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor:
            Colors.blue, // Mengubah warna item aktif menjadi biru
        unselectedItemColor: isDarkMode ? Colors.white70 : Colors.grey[600],
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.explore), label: 'Book Category'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: isDarkMode ? Colors.blueGrey[800] : Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BukuHub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.white,
                ),
              ),
              IconButton(
                icon: Icon(Icons.more_vert,
                    color: isDarkMode ? Colors.white : Colors.white),
                onPressed: () {
                  // Handle more options
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blueGrey[600] : Colors.blue[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Find your favorite book and enjoy it!',
                        style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.white),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/images/signup_logo.png',
                  height: 60,
                  width: 60,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Subject, Class, etc...',
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        filled: true,
        prefixIcon: Icon(Icons.search,
            color: isDarkMode ? Colors.white70 : Colors.grey),
        suffixIcon: IconButton(
          icon:
              Icon(Icons.tune, color: Theme.of(context).colorScheme.secondary),
          onPressed: () {
            _showFilterModal(context, isDarkMode);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildFilterButtons(bool isDarkMode) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterButton('All', isActive: true, isDarkMode: isDarkMode),
          const SizedBox(width: 10),
          _buildFilterButton('IPA', isDarkMode: isDarkMode),
          const SizedBox(width: 10),
          _buildFilterButton('IPS', isDarkMode: isDarkMode),
          const SizedBox(width: 10),
          _buildFilterButton('Bahasa', isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label,
      {bool isActive = false, required bool isDarkMode}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.secondary
            : isDarkMode
                ? Colors.grey[800]
                : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive
              ? Colors.white
              : isDarkMode
                  ? Colors.white
                  : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(bool isDarkMode) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final categories = ['IPS', 'IPA', 'Bahasa', 'Seni Budaya'];
        final images = [
          'assets/images/category3.png',
          'assets/images/category2.png',
          'assets/images/category4.png',
          'assets/images/category5.png'
        ];
        return _buildCategoryItem(categories[index], images[index], isDarkMode);
      },
    );
  }

  Widget _buildCategoryItem(String label, String imagePath, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              height: 80, // Atur tinggi gambar agar lebih kecil
              width: double.infinity,
              fit: BoxFit.cover, // Sesuaikan gambar dengan kontainer
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.book_rounded,
                  size: 16, color: isDarkMode ? Colors.grey[400] : Colors.grey),
              const SizedBox(width: 4),
              Text(
                '+50 Books',
                style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                    fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios,
                  size: 16, color: Theme.of(context).colorScheme.secondary),
            ],
          ),
        ],
      ),
    );
  }
}
