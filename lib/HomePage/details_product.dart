import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Product/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  ProductDetailScreen({required this.productId});

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>> product;
  bool isWishlist = false;
  bool isDescriptionExpanded = false;
  bool isReviewExpanded = false;
  int quantityToAdd = 1;
  TextEditingController quantityController = TextEditingController();

  // Fetch product details
  Future<Map<String, dynamic>> _fetchProductDetails() async {
    ApiService apiService = ApiService();
    List<Map<String, dynamic>> products = await apiService.getProductsByIds([widget.productId]);
    if (products.isNotEmpty) {
      return products[0]; // Return the first product if found
    } else {
      throw Exception('Product not found');
    }
  }

  // Handle wishlist toggle
  void _toggleWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> wishlistIds = prefs.getStringList('wishlistIds') ?? [];

    if (isWishlist) {
      // Nếu sản phẩm đã có trong wishlist, xóa đi
      wishlistIds.remove(widget.productId.toString());
    } else {
      // Thêm sản phẩm vào wishlist
      wishlistIds.add(widget.productId.toString());
    }

    // Lưu lại danh sách wishlist
    await prefs.setStringList('wishlistIds', wishlistIds);

    setState(() {
      // Cập nhật lại trạng thái yêu thích của nút trái tim
      isWishlist = !isWishlist; // Chuyển đổi trạng thái yêu thích
    });
  }

  // Kiểm tra nếu sản phẩm đã có trong wishlist khi màn hình khởi tạo
  Future<void> _checkIfProductInWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> wishlistIds = prefs.getStringList('wishlistIds') ?? [];

    setState(() {
      // Kiểm tra xem sản phẩm có trong wishlist không
      isWishlist = wishlistIds.contains(widget.productId.toString());
    });
  }


  // Save the product to SharedPreferences
  Future<void> _saveProductToCart(Map<String, dynamic> productData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Lấy dữ liệu cũ từ SharedPreferences, nếu có
    List<String> cartIds = prefs.getStringList('cartIds') ?? [];
    List<String> cartQuantities = prefs.getStringList('cartQuantities') ?? [];

    // Thêm ID sản phẩm và số lượng vào giỏ hàng
    cartIds.add(productData['id'].toString());
    cartQuantities.add(quantityToAdd.toString());

    // Lưu lại giỏ hàng vào SharedPreferences
    await prefs.setStringList('cartIds', cartIds);
    await prefs.setStringList('cartQuantities', cartQuantities);
  }


  // Show quantity dialog
  void _showQuantityDialog(Map<String, dynamic> productData) {
    // Reset the controller whenever the dialog is opened
    quantityController.text = quantityToAdd.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Quantity'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: quantityController, // Use the correct controller
                    onChanged: (value) {
                      setState(() {
                        quantityToAdd = int.tryParse(value) ?? 1;  // Update quantityToAdd
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Quantity',
                      errorText: quantityToAdd <= 0
                          ? 'Quantity must be greater than 0'
                          : (quantityToAdd > productData['stock']
                          ? 'Not enough stock!'
                          : null),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);  // Close the dialog on Cancel
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (quantityToAdd <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter a valid quantity!')),
                  );
                } else if (quantityToAdd > productData['stock']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Not enough stock!')),
                  );
                } else {
                  // Save product to SharedPreferences
                  _saveProductToCart(productData);

                  // Update stock in actual data
                  productData['stock'] -= quantityToAdd;

                  setState(() {
                    // Update UI if necessary
                  });

                  // Close the dialog after adding to cart
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    product = _fetchProductDetails();
    _checkIfProductInWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isWishlist ? Icons.favorite : Icons.favorite_border,
              color: isWishlist ? Colors.red : null,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Product Image
                  Image.network(
                    productData['images'].isNotEmpty
                        ? productData['images'][0]
                        : 'https://via.placeholder.com/150',
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),

                  // Product Info
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productData['title'],
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      if (productData['discountPercentage'] != 0)
                        Text(
                          'Discount: ${productData['discountPercentage']}%',
                          style: TextStyle(color: Colors.red),
                        ),
                      SizedBox(height: 4),
                      Text(
                        'Price: \$${productData['price']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          5,
                              (index) => Icon(
                            index < productData['rating']
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Tags, Brand, Dimensions, etc.
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tag: ${productData['tags'].join(', ')}'),
                          Text('Brand: ${productData['brand']}'),
                          Text('Dimensions: ${productData['dimensions']['width']} x ${productData['dimensions']['height']} x ${productData['dimensions']['depth']} cm'),
                          Text('Weight: ${productData['weight']} kg'),
                          Text('Stock: ${productData['stock']} units'),
                          Text('Category: ${productData['category']}'),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Product Description
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isDescriptionExpanded = !isDescriptionExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Description',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          isDescriptionExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                        ),
                      ],
                    ),
                  ),
                  if (isDescriptionExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(productData['description']),
                    ),

                  SizedBox(height: 16),

                  // Product Reviews
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isReviewExpanded = !isReviewExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Reviews (${productData['reviews'].length})',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          isReviewExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                        ),
                      ],
                    ),
                  ),
                  if (isReviewExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        children: productData['reviews']?.map<Widget>((review) {
                          return ListTile(
                            leading: Icon(Icons.account_circle),
                            title: Text(review['name']),
                            subtitle: Text(review['comment']),
                            trailing: Text('${review['rating']} stars'),
                          );
                        }).toList() ?? [],
                      ),
                    ),

                  SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _showQuantityDialog(productData); // Show quantity dialog
                        },
                        child: Text('Add to Cart'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CartScreen()),
                          );
                        },
                        child: Text('Go to Cart'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
