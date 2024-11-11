import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Product/api_service.dart';
import 'Profile/voucher_screen.dart';
import 'check_infor.dart';
import 'my_order.dart';
import 'search_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'details_product.dart';
import 'Profile/payment_screen.dart';
import 'Profile/setting_screen.dart';

class CartScreen extends StatefulWidget {
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  double totalPrice = 0;
  double discount = 0;
  String selectedVoucher = '';
  bool isVoucherApplied = false;
  int _selectedIndex = 2;

  String userName = '';
  String userEmail = '';
  String userAvatarUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    loadCartData();
  }

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
              userAvatarUrl = user['image'] ?? '';
              isLoading = false;
            });
          } else {
            setState(() => isLoading = false);
          }
        } else {
          setState(() => isLoading = false);
        }
      } catch (e) {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadCartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? cartIds = prefs.getStringList('cartIds');
    List<String>? cartQuantities = prefs.getStringList('cartQuantities');


    if (cartIds != null && cartQuantities != null && cartIds.length == cartQuantities.length) {
      for (int i = 0; i < cartIds.length; i++) {
        int productId = int.parse(cartIds[i]);
        int quantity = int.parse(cartQuantities[i]);
        await _fetchAndAddToCart(productId, quantity);
      }
    }
  }

  Future<void> _fetchAndAddToCart(int productId, int quantity) async {
    try {
      var productData = await _fetchProductDetails(productId);
      if (productData.isNotEmpty) {
        _addToCart(productData[0], quantity);
      }
    } catch (e) {
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProductDetails(int productId) async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(data['products']);
      var product = products.firstWhere(
            (item) => item['id'] == productId,
        orElse: () => {},
      );
      return product.isEmpty ? [] : [product];
    } else {
      throw Exception('Failed to load products');
    }
  }

  void _addToCart(Map<String, dynamic> productData, int quantity) {
    bool productExists = false;
    for (var item in cartItems) {
      if (item['id'] == productData['id']) {
        productExists = true;
        break;
      }
    }
    if (!productExists) {
      setState(() {
        cartItems.add({
          'id': productData['id'],
          'title': productData['title'],
          'price': productData['price'],
          'quantity': quantity,
          'stock': productData['stock'],
          'image': productData['images'][0],
        });
      });
    }
    _calculateTotalPrice();
  }

  void _calculateTotalPrice() {
    totalPrice = 0;
    for (var item in cartItems) {
      totalPrice += item['quantity'] * item['price'];
    }
    if (isVoucherApplied) {
      totalPrice -= (discount * totalPrice) / 100;
    }
  }

  void _increaseQuantity(Map<String, dynamic> productData) {
    if (productData['quantity'] < productData['stock']) {
      setState(() {
        productData['quantity']++;
      });
      _calculateTotalPrice();
    }
  }

  void _decreaseQuantity(Map<String, dynamic> productData) {
    if (productData['quantity'] > 1) {
      setState(() {
        productData['quantity']--;
      });
      _calculateTotalPrice();
    }
  }
  void _removeFromCart(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Xóa sản phẩm khỏi SharedPreferences
    await prefs.remove('product_id_${product['id']}');
    await prefs.remove('product_quantity_${product['id']}');


    // Cập nhật lại UI: Xóa sản phẩm khỏi danh sách giỏ hàng
    setState(() {
      cartItems.removeWhere((item) => item['id'] == product['id']);
      _calculateTotalPrice(); // Cập nhật lại tổng tiền sau khi xóa sản phẩm
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cart")),
      drawer: _buildDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildVoucherSection(),
            _buildCartItems(),
            _buildTotalPrice(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
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

  Widget _buildVoucherSection() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoucherScreen(),
          ),
        ).then((voucher) {
          if (voucher != null) {
            setState(() {
              selectedVoucher = voucher['name'];
              discount = voucher['discount'];
              isVoucherApplied = true;
            });
            _calculateTotalPrice();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        color: Colors.blue[50],
        child: Row(
          children: [
            Icon(Icons.card_giftcard),
            SizedBox(width: 10),
            Text('Voucher: $selectedVoucher', style: TextStyle(fontSize: 18)),
            Spacer(),
            Text('Apply Voucher'),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        var product = cartItems[index];
          return Card(
            elevation: 5,
            margin: EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(12.0),  // Padding xung quanh toàn bộ Row
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Hình ảnh sản phẩm
                    Image.network(
                      product['image'],
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,  // Đảm bảo hình ảnh không bị méo
                    ),

                    // Tiêu đề sản phẩm, có thể xuống dòng và cắt bớt nếu dài
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),  // Padding bên trái để không quá sát
                        child: Text(
                          product['title'],
                          style: TextStyle(fontSize: 14),  // Điều chỉnh font size nếu cần
                          maxLines: 2,  // Cho phép tối đa 2 dòng
                          overflow: TextOverflow.ellipsis,  // Cắt bớt và thêm "..."
                          softWrap: true,  // Cho phép tự động xuống dòng
                        ),
                      ),
                    ),

                    // Các biểu tượng để tăng/giảm số lượng sản phẩm
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => _decreaseQuantity(product),
                          icon: Icon(Icons.remove),
                        ),
                        Text(product['quantity'].toString()),  // Số lượng sản phẩm
                        IconButton(
                          onPressed: () => _increaseQuantity(product),
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),

                    // Giá của sản phẩm
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),  // Padding bên trái để không quá sát
                      child: Text(
                        '\$${(product['price'] * product['quantity']).toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Biểu tượng thùng rác để xóa sản phẩm khỏi giỏ hàng
                    IconButton(
                      onPressed: () => _removeFromCart(product),
                      icon: Icon(Icons.delete),
                      color: Colors.red,  // Đặt màu đỏ cho biểu tượng thùng rác
                    ),
                  ],
                ),
              ),

          );
      },
    );
  }

  Widget _buildTotalPrice() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Hiển thị tổng giá trị
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('\$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, color: Colors.green)),
            ],
          ),
          SizedBox(height: 20),
          // Nút "Pay" ở chính giữa màn hình
          ElevatedButton(
            onPressed: () {
              // Điều hướng tới màn hình PaymentScreen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CheckInfoScreen(email: userEmail)),
              );
            },
            child: Text('Pay Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50), // Đặt kích thước nút
              backgroundColor: Colors.blue, // Màu nền nút
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Bo góc nút
              ),
            ),
          ),
        ],
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

            Navigator.popUntil(context, ModalRoute.withName('/'));
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
