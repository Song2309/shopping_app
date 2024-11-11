import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../cart_screen.dart'; // Đảm bảo bạn đã tạo CartScreen trước

class WishlistScreen extends StatefulWidget {
  @override
  _WishlistScreenState createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late Future<List<Map<String, dynamic>>> wishlistProducts;

  @override
  void initState() {
    super.initState();
    wishlistProducts = _loadWishlistProducts(); // Tải danh sách yêu thích
  }

  // Hàm tải sản phẩm yêu thích từ SharedPreferences và lấy thông tin từ API
  Future<List<Map<String, dynamic>>> _loadWishlistProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Đảm bảo wishlistIds là một danh sách trống nếu null
    List<String> wishlistIds = prefs.getStringList('wishlistIds') ?? [];

    List<Map<String, dynamic>> products = [];

    // Lấy thông tin sản phẩm từ API bằng cách sử dụng IDs
    for (String productId in wishlistIds) {
      var response = await http.get(Uri.parse('https://dummyjson.com/products/$productId'));
      if (response.statusCode == 200) {
        // Giải mã và thêm sản phẩm vào danh sách
        products.add(json.decode(response.body));
      } else {
        throw Exception('Failed to load product');
      }
    }

    return products;
  }

  // Hàm thêm sản phẩm vào giỏ hàng
  Future<void> _addToCart(Map<String, dynamic> productData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cartIds = prefs.getStringList('cartIds') ?? [];
    List<String> cartQuantities = prefs.getStringList('cartQuantities') ?? [];

    // Thêm ID sản phẩm và số lượng vào giỏ hàng
    cartIds.add(productData['id'].toString());
    cartQuantities.add('1');  // Mặc định là thêm 1 sản phẩm

    // Lưu giỏ hàng vào SharedPreferences
    await prefs.setStringList('cartIds', cartIds);
    await prefs.setStringList('cartQuantities', cartQuantities);

    // Hiển thị thông báo khi sản phẩm đã được thêm vào giỏ hàng
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${productData['title']} added to cart!'),
    ));
  }

  // Hàm xóa sản phẩm khỏi wishlist
  Future<void> _removeFromWishlist(String productId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> wishlistIds = prefs.getStringList('wishlistIds') ?? [];

    // Xóa sản phẩm khỏi wishlist
    wishlistIds.remove(productId);

    // Lưu lại danh sách wishlist vào SharedPreferences
    await prefs.setStringList('wishlistIds', wishlistIds);

    // Cập nhật lại UI
    setState(() {
      wishlistProducts = _loadWishlistProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: wishlistProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your wishlist is empty.'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Hai cột
              crossAxisSpacing: 10.0, // Khoảng cách giữa các sản phẩm
              mainAxisSpacing: 10.0, // Khoảng cách giữa các dòng
              childAspectRatio: 0.7, // Tỷ lệ chiều rộng và chiều cao của từng sản phẩm
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product['thumbnail'], // Sử dụng đường dẫn hình ảnh từ API
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        product['title'],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        '\$${product['price']}',
                        style: TextStyle(fontSize: 14, color: Colors.green),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            _removeFromWishlist(product['id'].toString());
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _addToCart(product);
                          },
                          child: Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
