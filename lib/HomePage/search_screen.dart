import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'cart_screen.dart';
import 'home_screen.dart';
import 'my_order.dart';
import 'profile_screen.dart';
import 'Product/api_service.dart';
import 'details_product.dart';
import 'Profile/setting_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Text editing controller for search input
  TextEditingController _searchController = TextEditingController();
  RxList<String> searchHistory = <String>[].obs;
  bool isFilterVisible = false;
  int _selectedIndex = 1; // Default selection is Search
  late Future<List<Map<String, dynamic>>> _searchResults;
  List<Map<String, dynamic>> _allProducts = [];
  String userName = '';
  String userEmail = '';
  String userAvatarUrl = '';
  bool isLoading = true;

  String _sortBy = 'Price: Low to High'; // Default sort option
  List<String> _selectedCategories = [];
  TextEditingController _minPriceController = TextEditingController();
  TextEditingController _maxPriceController = TextEditingController();

  // 4 Category options
  List<String> _categories = ['Beauty', 'Fragrances', 'Furniture', 'Groceries'];

  // Sort options
  List<String> _sortOptions = [
    'Price: Low to High',
    'Price: High to Low',
    'Name: A to Z',
    'Name: Z to A',
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    _searchResults = _getRandomProducts();
    fetchUserData(); // Fetch user data when screen is loaded
  }

  // Fetch user data from shared preferences and an API
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null && email.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse('https://dummyjson.com/users'));
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          final user = (data['users'] as List).firstWhere(
                (user) => user['email'] == email,
            orElse: () => {},
          );

          if (user.isNotEmpty) {
            setState(() {
              userName = '${user['firstName']} ${user['lastName']}';
              userEmail = user['email'];
              userAvatarUrl = user['image'] ?? ''; // assuming the avatar URL is stored in 'image'
              isLoading = false;
            });
          } else {
            setState(() => isLoading = false);
            print('User not found!');
          }
        } else {
          setState(() => isLoading = false);
          print('Failed to load user data');
        }
      } catch (e) {
        setState(() => isLoading = false);
        print('Error fetching user data: $e');
      }
    } else {
      setState(() => isLoading = false);
      print('No email found in SharedPreferences');
    }
  }

  // Load search history from shared preferences
  void _loadSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? history = prefs.getStringList('search_history');
    if (history != null) {
      searchHistory.addAll(history);
    }
  }

  // Save search history to shared preferences
  void _saveSearchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('search_history', searchHistory.toList());
  }

  // Add a new query to the search history
  void _addToSearchHistory(String query) {
    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
      if (searchHistory.length > 10) {
        searchHistory.removeLast();
      }
      _saveSearchHistory(); // Save history after update
    }
  }

  // Handle search query submission
  void _onSearchSubmit(String query) {
    if (query.isNotEmpty) {
      _addToSearchHistory(query);
      setState(() {
        _searchResults = ApiService().fetchProducts().then((products) {
          _allProducts = products;
          return _filterSearchResults(query, products); // Filter products based on query
        });
      });
    }
  }

  // Filter the product list based on search query
  List<Map<String, dynamic>> _filterSearchResults(String query, List<Map<String, dynamic>> products) {
    return products.where((product) {
      return product['title'].toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  // Fetch random products when no search is performed
  Future<List<Map<String, dynamic>>> _getRandomProducts() async {
    List<Map<String, dynamic>> products = await ApiService().fetchProducts();
    products.shuffle();
    return products.take(5).toList(); // Return 5 random products
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSearchHistory(); // Load search history when the screen is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Search"),
        centerTitle: true,
        actions: [
          // Filter button in the AppBar
          IconButton(
            icon: Icon(FontAwesomeIcons.filter),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      drawer: _buildDrawer(),
      endDrawer: _buildFilterDrawer(),
      body: SingleChildScrollView( // Prevent screen overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search input field
            _buildSearchField(),

            // Search history (only when search input is empty)
            if (_searchController.text.isEmpty) _buildSearchHistory(),

            // Search results
            _buildSearchResults(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Search input field
  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onSubmitted: _onSearchSubmit, // Handle search submission (Enter key)
      decoration: InputDecoration(
        labelText: "Search for products",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
        suffixIcon: IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchResults = _getRandomProducts(); // Load random products when cleared
            });
          },
        ),
      ),
    );
  }

  Widget _buildSearchHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Search History", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Obx(() {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: searchHistory.length,
            itemBuilder: (context, index) {
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(searchHistory[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        searchHistory.removeAt(index);
                        _saveSearchHistory(); // Update history when an item is removed
                      });
                    },
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  // Search results display
  Widget _buildSearchResults() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No results found.'));
        } else {
          return ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var product = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  leading: Image.network(product['thumbnail'] ?? ''),
                  title: Text(product['title'] ?? 'No Title'),
                  subtitle: Text("\$${product['price']}"),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(productId: product['id']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }


  // Drawer menu
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            currentAccountPicture: isLoading
                ? CircularProgressIndicator()
                : CircleAvatar(
              backgroundImage: isLoading
                  ? AssetImage('assets/avatar.png')
                  : NetworkImage(userAvatarUrl),
            ),
            accountName: isLoading
                ? Text("Loading...")
                : Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            accountEmail: isLoading ? Text("Loading...") : Text(userEmail, style: TextStyle(fontSize: 12)),
          ),
          _buildDrawerItem(Icons.search, 'Discover', () => Get.to(() => SearchScreen())),
          _buildDrawerItem(Icons.shopping_cart, 'My Orders', () => Get.to(() => MyOrderScreen())),
          _buildDrawerItem(Icons.account_circle, 'My Profile', () => Get.to(() => ProfileScreen())),
          _buildDrawerItem(Icons.settings, 'Settings', () => Get.to(() => SettingScreen())),
          _buildDrawerItem(Icons.help, 'Support', () {}),
          _buildDrawerItem(Icons.info, 'About Us', () {}),
          _buildDarkModeSwitch(),
        ],
      ),
    );
  }
  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }

  ListTile _buildDarkModeSwitch() {
    return ListTile(
      title: Text('Dark Mode'),
      trailing: Switch(
        value: Theme.of(context).brightness == Brightness.dark,
        onChanged: (value) {
          final theme = Theme.of(context);
          final newTheme = theme.brightness == Brightness.dark
              ? ThemeData.light()
              : ThemeData.dark();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MaterialApp(
                theme: newTheme,
                home: HomeScreen(),
              ),
            ),
          );
        },
      ),
    );
  }

  // Build filter drawer
  Widget _buildFilterDrawer() {
    return Drawer(
      child: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Sort By options
            Text('Sort By:', style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _sortBy,
              onChanged: (String? newValue) {
                setState(() {
                  _sortBy = newValue!;
                });
              },
              items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            SizedBox(height: 16),

            // Category options (Checkboxes)
            Text('Categories:', style: TextStyle(fontSize: 16)),
            ..._categories.map((category) {
              return CheckboxListTile(
                title: Text(category),
                value: _selectedCategories.contains(category),
                onChanged: (bool? value) {
                  setState(() {
                    if (value!) {
                      _selectedCategories.add(category);
                    } else {
                      _selectedCategories.remove(category);
                    }
                  });
                },
              );
            }).toList(),

            SizedBox(height: 16),

            // Price range input
            Text('Price:', style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    decoration: InputDecoration(
                      labelText: 'Min Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    decoration: InputDecoration(
                      labelText: 'Max Price',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),

            // Apply Filter button
            ElevatedButton(
              onPressed: () {
                // Handle filter logic and return to search results
                _applyFilters();
              },
              child: Text('Apply Filter'),
            ),
          ],
        ),
      ),
    );
  }

  // Handle applying the filters
  void _applyFilters() {
    // Lấy các tiêu chí bộ lọc (sắp xếp, danh mục, phạm vi giá)
    String sortOption = _sortBy;
    List<String> selectedCategories = _selectedCategories;
    double? minPrice = _minPriceController.text.isNotEmpty
        ? double.tryParse(_minPriceController.text)
        : null;
    double? maxPrice = _maxPriceController.text.isNotEmpty
        ? double.tryParse(_maxPriceController.text)
        : null;

    // Lọc danh sách sản phẩm theo các tiêu chí
    List<Map<String, dynamic>> filteredProducts = _allProducts;

    // Lọc theo danh mục
    if (selectedCategories.isNotEmpty) {
      filteredProducts = filteredProducts.where((product) {
        return selectedCategories.contains(product['category']);
      }).toList();
    }

    // Lọc theo giá
    if (minPrice != null) {
      filteredProducts = filteredProducts.where((product) {
        return product['price'] >= minPrice;
      }).toList();
    }
    if (maxPrice != null) {
      filteredProducts = filteredProducts.where((product) {
        return product['price'] <= maxPrice;
      }).toList();
    }

    // Sắp xếp sản phẩm theo tiêu chí chọn
    switch (sortOption) {
      case 'Price: Low to High':
        filteredProducts.sort((a, b) => a['price'].compareTo(b['price']));
        break;
      case 'Price: High to Low':
        filteredProducts.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Name: A to Z':
        filteredProducts.sort((a, b) => a['title'].compareTo(b['title']));
        break;
      case 'Name: Z to A':
        filteredProducts.sort((a, b) => b['title'].compareTo(a['title']));
        break;
    }

    setState(() {
      _searchResults = Future.value(filteredProducts); // Cập nhật kết quả tìm kiếm
    });

    Navigator.pop(context); // Đóng Drawer bộ lọc
  }


  // Bottom navigation bar
  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          case 1:
            Navigator.popUntil(context, ModalRoute.withName('/'));
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartScreen()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
          backgroundColor: Colors.blue,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
          backgroundColor: Colors.blue,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
          backgroundColor: Colors.blue,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Profile',
          backgroundColor: Colors.blue,
        ),
      ],
    );
  }
}
