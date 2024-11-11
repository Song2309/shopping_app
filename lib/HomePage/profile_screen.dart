import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'my_order.dart';
import 'search_screen.dart';
import 'cart_screen.dart';
import 'Profile/setting_screen.dart';
import 'Profile/address_screen.dart';
import 'Profile/payment_screen.dart';
import 'Profile/voucher_screen.dart';
import 'Profile/wishlist_screen.dart';
import 'Profile/rate_app_screen.dart';
import 'SignIn/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 3; // Mặc định lựa chọn là Profile
  String userName = ''; // Lấy tên user từ profile_screen.dart
  String userEmail = ''; // Lấy Gmail từ profile_screen.dart
  String userAvatarUrl = ''; // Link avatar
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    fetchUserData(); // Fetch user data when screen is loaded
  }

  // Fetch user data based on the logged-in email
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
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      drawer: _buildDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView(
          children: [
            // Khung 1: Avatar, Name và Email của User + Setting Icon
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: isLoading
                        ? AssetImage('assets/avatar.png') // Placeholder image
                        : NetworkImage(userAvatarUrl),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isLoading ? "Loading..." : userName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Khung 2: Address
            _buildProfileItem("Address", Icons.location_on, AddressScreen()),

            // Khung 3: Payment Method
            _buildProfileItem("Payment Method", Icons.payment, PaymentScreen()),

            // Khung 4: Voucher
            _buildProfileItem("Voucher", Icons.card_giftcard, VoucherScreen()),

            // Khung 5: My Wishlist
            _buildProfileItem("My Wishlist", Icons.favorite_border, WishlistScreen()),

            // Khung 6: Rate This App
            _buildProfileItem("Rate this app", Icons.star_border, RateScreen()),

            // Khung 7: Log Out
            ListTile(
              title: Container(
                padding: const EdgeInsets.all(14.0),  // Thêm padding cho title nếu cần
                decoration: BoxDecoration(
                  color: Colors.white,  // Màu nền của ListTile
                  borderRadius: BorderRadius.circular(8.0),  // Bo tròn góc
                  border: Border.all(
                    color: Colors.white,  // Màu viền
                    width: 1.5,  // Độ dày của viền
                  ),
                ),
                child: ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text("Log Out"),
                  onTap: () {
                    // Đăng xuất và quay lại màn hình đăng nhập hoặc màn hình khác
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()), // Ví dụ điều hướng về màn hình đăng nhập
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // Helper method to build profile items
  Widget _buildProfileItem(String title, IconData icon, Widget screen) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,  // Màu nền của ListTile
          borderRadius: BorderRadius.circular(8.0),  // Bo tròn góc
          border: Border.all(
            color: Colors.white,  // Màu viền
            width: 1.5,  // Độ dày của viền
          ),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,  // Loại bỏ padding mặc định của ListTile để tùy chỉnh
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Đảm bảo icon và text cách xa nhau
            children: [
              Row(
                children: [
                  Icon(icon, size: 24),  // Thêm icon
                  SizedBox(width: 8),  // Khoảng cách giữa icon và title
                  Text(title),  // Tiêu đề
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 16),  // Thêm icon bên phải (ví dụ: mũi tên)
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => screen),
            );
          },
        ),
      ),
    );
  }
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

            Navigator.popUntil(context, ModalRoute.withName('/'));
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
