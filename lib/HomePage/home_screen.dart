import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'cart_screen.dart';
import 'my_order.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'Product/api_service.dart';
import 'category_screen.dart';  // Add CategoryScreen import if necessary
import 'details_product.dart';
import 'Profile/setting_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // RxBool to track selected categories
  RxBool isFragrancesSelected = false.obs;
  RxBool isGroceriesSelected = false.obs;
  RxBool isFurnitureSelected = false.obs;
  RxBool isBeautySelected = false.obs;
  bool hasNotification = true;
  int _selectedIndex = 0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Category list
  final List<String> categories = ["Beauty", "Fragrances", "Furniture", "Groceries"];

  // Category icons
  final List<IconData> categoryIcons = [
    FontAwesomeIcons.fire,  // Beauty
    FontAwesomeIcons.bottleDroplet,  // Fragrances
    FontAwesomeIcons.bed,  // Furniture
    FontAwesomeIcons.store,  // Groceries
  ];

  // Update button state for categories
  void _updateButtonState(String category) {
    isFragrancesSelected.value = category == "Fragrances";
    isGroceriesSelected.value = category == "Groceries";
    isFurnitureSelected.value = category == "Furniture";
    isBeautySelected.value = category == "Beauty";
  }

  // Future variables for product data
  Future<List<int>>? topSaleIds;
  Future<List<int>>? recommendedIds;
  Future<List<int>>? hotProductIds;

  String userName = ''; // Lấy tên user từ profile_screen.dart
  String userEmail = ''; // Lấy Gmail từ profile_screen.dart
  String userAvatarUrl = ''; // Link avatar
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when screen is loaded
    // Fetch product data
    topSaleIds = ApiService().getTopSaleProduct().timeout(Duration(seconds: 10), onTimeout: () => []);
    recommendedIds = ApiService().getRecommendedProduct().timeout(Duration(seconds: 10), onTimeout: () => []);
    hotProductIds = ApiService().getHotProduct().timeout(Duration(seconds: 10), onTimeout: () => []);
  }
  Future<void> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email'); // Get email from shared preferences

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
              userName = user['firstName'] + ' ' + user['lastName'];
              userEmail = user['email'];
              userAvatarUrl = user['image'] ?? ''; // assuming the avatar URL is stored in 'image'
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
            print('User not found!');
          }
        } else {
          setState(() {
            isLoading = false;
          });
          print('Failed to load user data');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print('Error fetching user data: $e');
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('No email found in SharedPreferences');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title:
        Text('Home'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  // Hiển thị cửa sổ thông báo giống Drawer khi nhấn nút notification
                  _scaffoldKey.currentState?.openEndDrawer();
                },
              ),
              // Chấm đỏ góc trên bên phải khi có thông báo mới
              if (hasNotification)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // Ẩn chấm đỏ khi nhấn vào nó
                        hasNotification = false;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: _buildDrawer(),
      endDrawer: _buildEndDrawer(),
      body: SingleChildScrollView(  // Bao toàn bộ nội dung trong SingleChildScrollView để cuộn dọc
        child: Column(
          children: [
            // Horizontal buttons for category selection
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.asMap().map((index, category) {
                  return MapEntry(index, Obx(() {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getButtonColor(category), // Dynamic button color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                        onPressed: () {
                          _updateButtonState(category);
                          Get.to(CategoryScreen(category: category));
                        },
                        icon: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              categoryIcons[index],
                              size: 24,
                              color: _getTextColor(category),
                            ),
                            Text(
                              category,
                              style: TextStyle(fontSize: 14, color: _getTextColor(category)),
                            ),
                          ],
                        ),
                        label: Container(),
                      ),
                    );
                  }));
                }).values.toList(),
              ),
            ),
            // Top Sale Section
            buildProductSection('Top Sale', topSaleIds),
            // Recommended Section
            buildProductSection('Recommended', recommendedIds),
            // Hot Products Section
            buildProductSection('Hot Products', hotProductIds),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Get button background color based on category selection
  Color _getButtonColor(String category) {
    final selectedCategory = {
      "Fragrances": isFragrancesSelected,
      "Groceries": isGroceriesSelected,
      "Furniture": isFurnitureSelected,
      "Beauty": isBeautySelected,
    }[category];

    if (selectedCategory == null || !selectedCategory.value) {
      return Colors.grey;
    }

    return Colors.blue;
  }

  // Get text color for button
  Color _getTextColor(String category) {
    final selectedCategory = {
      "Fragrances": isFragrancesSelected,
      "Groceries": isGroceriesSelected,
      "Furniture": isFurnitureSelected,
      "Beauty": isBeautySelected,
    }[category];

    if (selectedCategory == null || !selectedCategory.value) {
      return Colors.black;
    }

    return Colors.white;
  }

  // Build product section with FutureBuilder
  Widget buildProductSection(String sectionTitle, Future<List<int>>? productIdsFuture) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title and Show All button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                sectionTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryScreen(category: sectionTitle),
                    ),
                  );
                },
                child: Text('Show All'),
              ),
            ],
          ),
          // FutureBuilder to fetch product IDs
          FutureBuilder<List<int>>(
            future: productIdsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No products available'));
              }

              final productIds = snapshot.data!;

              // Fetch product details by IDs
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchProductsByIds(productIds),
                builder: (context, productSnapshot) {
                  if (productSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (productSnapshot.hasError) {
                    return Center(child: Text('Error: ${productSnapshot.error}'));
                  }
                  if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                    return Center(child: Text('No products available'));
                  }

                  final products = productSnapshot.data!;

                  // Giới hạn số lượng sản phẩm hiển thị (4 sản phẩm đầu tiên)
                  final limitedProducts = products.take(4).toList();

                  return Container(
                    height: 250,  // Đặt chiều cao cố định cho hàng sản phẩm
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: limitedProducts.length,
                      itemBuilder: (context, index) {
                        final product = limitedProducts[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              // Chuyển đến màn hình chi tiết sản phẩm khi nhấn vào sản phẩm
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(
                                    productId: product['id'], // Truyền ID sản phẩm qua constructor
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                    child: Image.network(
                                      product['thumbnail'] ?? '',
                                      height: 120,  // Điều chỉnh kích thước ảnh
                                      width: 120,   // Điều chỉnh kích thước ảnh
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['title'] ?? 'No Title',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '\$${product['price'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  // Fetch product details based on IDs (using raw data)
  Future<List<Map<String, dynamic>>> _fetchProductsByIds(List<int> productIds) async {
    ApiService apiService = ApiService();
    List<Map<String, dynamic>> allProducts = await apiService.fetchProducts();
    return allProducts.where((product) => productIds.contains(product['id'])).toList();
  }
  // Method to show EndDrawer when notification icon is pressed
  void _showNotificationEndDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }



  // Build the EndDrawer content
  Widget _buildEndDrawer() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      padding: EdgeInsets.all(15.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(color: Colors.black),
          SizedBox(height: 10),
          // Giả lập một số thông báo
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Thông báo 1: Bạn có tin nhắn mới'),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Thông báo 2: Cập nhật mới đã có'),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Thông báo 3: Sản phẩm mới có sẵn'),
          ),
        ],
      ),
    );
  }
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            currentAccountPicture: isLoading
                ? CircularProgressIndicator()
                : CircleAvatar(
              backgroundImage: isLoading
                  ? AssetImage('assets/avatar.png')
                  : NetworkImage(userAvatarUrl),
            ),
            accountName: isLoading
                ? Text("Loading...")
                : Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
            accountEmail: isLoading ? Text("Loading...") : Text(userEmail, style: TextStyle(fontSize: 14, color: Colors.black)),
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

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.popUntil(context, ModalRoute.withName('/'));
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
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
