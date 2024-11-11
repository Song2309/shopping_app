import 'package:flutter/material.dart';
import 'Product/api_service.dart';

class CategoryScreen extends StatelessWidget {
  final String category;

  CategoryScreen({required this.category});

  // Fetch products by category directly as raw data (Map<String, dynamic>)
  Future<List<Map<String, dynamic>>> fetchCategoryProducts(String category) async {
    ApiService apiService = ApiService();

    // Fetch product IDs by category from one of the functions (getTopSaleProduct, getRecommendedProduct, or getHotProduct)
    List<int> productIds;

    // Use one of these functions to get the product IDs you need
    switch (category) {
      case 'Beauty':
        productIds = await apiService.getProductByCategory('beauty');
        break;
      case 'Fragrances':
        productIds = await apiService.getProductByCategory('fragrances');
        break;
      case 'Furniture':
        productIds = await apiService.getProductByCategory('furniture');
        break;
      case 'Groceries':
        productIds = await apiService.getProductByCategory('groceries');
        break;
      case 'Top Sale':
        productIds = await apiService.getTopSaleProduct(); // Lấy ID của sản phẩm Top Sale
        break;
      case 'Recommended':
        productIds = await apiService.getRecommendedProduct(); // Lấy ID của sản phẩm Recommended
        break;
      case 'Hot Products':
        productIds = await apiService.getHotProduct(); // Lấy ID của sản phẩm Hot
        break;
      default:
      // Xử lý trường hợp không có category khớp
        productIds = [];
        break;
    }

    // Fetch detailed product information by IDs
    List<Map<String, dynamic>> products = await apiService.getProductsByIds(productIds);
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Products'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchCategoryProducts(category),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products available in this category'));
          }
          final products = snapshot.data!;

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product['title'] ?? 'No Title'),
                subtitle: Text('\$${product['price'] ?? 'N/A'}'),
                leading: Image.network(product['thumbnail'] ?? ''),
                onTap: () {
                  // Handle tap (navigate to product details screen, for example)
                },
              );
            },
          );
        },
      ),
    );
  }
}
