import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  // Tham số truyền vào từ màn hình trước đó
  final String address;
  final String paymentCardNumber;
  final String paymentCardExpire;
  final String paymentCardType;

  // Constructor để nhận dữ liệu từ màn hình trước
  OrderDetailsScreen({
    required this.address,
    required this.paymentCardNumber,
    required this.paymentCardExpire,
    required this.paymentCardType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Address: $address', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Payment Card Number: $paymentCardNumber', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Card Expiry: $paymentCardExpire', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Card Type: $paymentCardType', style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Quay lại màn hình trước đó
                Navigator.pop(context);
              },
              child: Text('Back to Check Info'),
            ),
          ],
        ),
      ),
    );
  }
}
