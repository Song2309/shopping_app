import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiUrl = 'https://dummyjson.com/products';

  // Fetch products from the API directly as maps
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productsData = data['products'];
      return productsData.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Top Sale - Filter products with rating > 3
  Future<List<int>> getTopSaleProduct() async {
    List<Map<String, dynamic>> allProducts = await fetchProducts();
    List<Map<String, dynamic>> topSaleProducts = allProducts
        .where((product) => product['rating'] > 3)
        .toList();
    return topSaleProducts.take(10).map((product) => product['id'] as int).toList();
  }

  // Recommended - Sort products by the lowest price
  Future<List<int>> getRecommendedProduct() async {
    List<Map<String, dynamic>> allProducts = await fetchProducts();
    allProducts.sort((a, b) => a['price'].compareTo(b['price']));
    return allProducts.take(10).map((product) => product['id'] as int).toList();
  }

  // Hot Product - Sort products by the highest discount percentage
  Future<List<int>> getHotProduct() async {
    List<Map<String, dynamic>> allProducts = await fetchProducts();
    allProducts.sort((a, b) => b['discountPercentage'].compareTo(a['discountPercentage']));
    return allProducts.take(10).map((product) => product['id'] as int).toList();
  }

  // Get products by category
  Future<List<int>> getProductByCategory(String category) async {
    List<Map<String, dynamic>> allProducts = await fetchProducts();
    List<Map<String, dynamic>> categoryProducts = allProducts
        .where((product) => product['category'].toLowerCase() == category.toLowerCase())
        .toList();
    return categoryProducts.map((product) => product['id'] as int).toList();
  }

  // Fetch product details by list of IDs
  Future<List<Map<String, dynamic>>> getProductsByIds(List<int> ids) async {
    List<Map<String, dynamic>> allProducts = await fetchProducts();
    return allProducts.where((product) => ids.contains(product['id'])).toList();
  }
  Future<List<Map<String, dynamic>>> fetchAndConvertProducts() async {
    try {
      List<Map<String, dynamic>> products = await fetchProducts();
      return products;
    } catch (e) {
      throw Exception('Failed to fetch and convert products: $e');
    }
  }
}