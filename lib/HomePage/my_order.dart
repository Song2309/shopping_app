import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Profile/rate_app_screen.dart';
import 'check_order_screen.dart';
import 'rate_product_screen.dart';

// Assuming RateScreen is in the same file or imported.
class MyOrderScreen extends StatefulWidget {
  @override
  _MyOrderScreenState createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  List<Map<String, dynamic>> orders = [
    {
      'orderNumber': 'ORD12345',
      'date': '2024-10-10',
      'status': 'Pending',
      'trackingNumber': _generateTrackingNumber(),
      'quantity': 2,
      'totalPrice': 100.0,
      'productTitle': 'Wireless Mouse',
      'price': 50.0,
      'voucher': 'DISCOUNT10',
    },
    {
      'orderNumber': 'ORD12346',
      'date': '2024-10-12',
      'status': 'Delivered',
      'trackingNumber': _generateTrackingNumber(),
      'quantity': 1,
      'totalPrice': 50.0,
      'productTitle': 'Bluetooth Headphones',
      'price': 50.0,
      'voucher': 'DISCOUNT5',
    },
    {
      'orderNumber': 'ORD12347',
      'date': '2024-10-13',
      'status': 'Canceled',
      'trackingNumber': _generateTrackingNumber(),
      'quantity': 3,
      'totalPrice': 150.0,
      'productTitle': 'Smart Watch',
      'price': 50.0,
      'voucher': 'DISCOUNT15',
    },
  ];

  String selectedStatus = 'All';
  String userAddress = '123 Main Street, Cityville, TX 12345';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredOrders = orders;
    if (selectedStatus != 'All') {
      filteredOrders =
          orders.where((order) => order['status'] == selectedStatus).toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: Column(
        children: [
          // Filter buttons (Pending, Delivered, Cancelled)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCategoryButton('Pending'),
                _buildCategoryButton('Delivered'),
                _buildCategoryButton('Canceled'),
              ],
            ),
          ),
          // List of orders
          Expanded(
            child: ListView.builder(
              itemCount: filteredOrders.length,
              itemBuilder: (context, index) {
                final order = filteredOrders[index];
                return GestureDetector(
                  onTap: () {
                    _showOrderDetails(context, order);
                  },
                  child: Card(
                    margin: EdgeInsets.all(20),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Order Number
                          Text(
                            'Order Number: ${order['orderNumber']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // In đậm
                              color:
                                  Colors.black, // Màu mặc định cho Order Number
                            ),
                          ),
                          // Date
                          Text(
                            'Date: ${order['date']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // In đậm
                              color: Colors.black, // Màu mặc định cho Date
                            ),
                          ),
                          // Status với màu tùy thuộc vào giá trị
                          Row(
                            children: [
                              Text(
                                'Status: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // In đậm cho phần "Status:"
                                  color: Colors.black, // Màu mặc định
                                ),
                              ),
                              Text(
                                order['status'],
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  // Không in đậm cho trạng thái
                                  color: _getStatusColor(order[
                                      'status']), // Màu sắc cho trạng thái
                                ),
                              ),
                            ],
                          ),
                          // Tracking Number
                          Text(
                            'Tracking Number: ${order['trackingNumber']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // In đậm
                              color: Colors
                                  .black, // Màu mặc định cho Tracking Number
                            ),
                          ),
                          // Quantity
                          Text(
                            'Quantity: ${order['quantity']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // In đậm
                              color: Colors.black, // Màu mặc định cho Quantity
                            ),
                          ),
                          // Total Price
                          Text(
                            'Total Price: \$${order['totalPrice']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // In đậm
                              color:
                                  Colors.black, // Màu mặc định cho Total Price
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Delivered':
        return Colors.green; // Màu xanh lá cho "Delivered"
      case 'Pending':
        return Colors.orange; // Màu cam cho "Pending"
      case 'Canceled':
        return Colors.red; // Màu đỏ cho "Canceled"
      default:
        return Colors.black; // Màu mặc định nếu không có giá trị phù hợp
    }
  }

  // Category button for filtering orders
  Widget _buildCategoryButton(String category) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedStatus = category;
          });
        },
        child: Text(category),
      ),
    );
  }

  // Generate random tracking number
  static String _generateTrackingNumber() {
    final random = Random();
    return 'TRACK' +
        (random.nextInt(10000) + 1000)
            .toString(); // Create a random tracking number
  }

  // Show order details when clicked
  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order info
                _buildOrderInfo(order),
                SizedBox(height: 10),
                // Shipping address
                _buildAddress(),
                SizedBox(height: 10),
                // Product info
                _buildProductInfo(order),
                // Không cần thêm nút "Rate this Product" trong phần content nữa
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Nút "Close"
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
                SizedBox(width: 10), // Thêm khoảng cách giữa các nút
                if (order['status'] == 'Delivered')
                  ElevatedButton(
                    onPressed: () {
                      Get.to(RateProductScreen());
                    },
                    child: Text('Rate this Product'),
                  ),
                if (order['status'] == 'Pending')
                  ElevatedButton(
                    onPressed: () {
                      Get.to(CheckOrderScreen());
                    },
                    child: Text('Check the order'),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Build order info (Order number, Date, Status, Tracking number)
  Widget _buildOrderInfo(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order Number: ${order['orderNumber']}'),
        Text('Date: ${order['date']}'),
        Text('Status: ${order['status']}'),
        Text('Tracking Number: ${order['trackingNumber']}'),
      ],
    );
  }

  // Build shipping address
  Widget _buildAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shipping Address:'),
        Text(userAddress), // Address from the variable
      ],
    );
  }

  // Build product info (Product Title, Price, Quantity, Voucher, Total Price)
  Widget _buildProductInfo(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Product Title: ${order['productTitle']}'),
        Text('Price: \$${order['price']}'),
        Text('Quantity: ${order['quantity']}'),
        Text('Voucher: ${order['voucher']}'),
        Text('Total Price: \$${order['totalPrice']}'),
      ],
    );
  }
}
