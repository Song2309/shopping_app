import 'package:flutter/material.dart';

class AddPaymentScreen extends StatefulWidget {
  @override
  _AddPaymentScreenState createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final TextEditingController cardExpireController = TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardTypeController = TextEditingController();
  final TextEditingController currencyController = TextEditingController();
  final TextEditingController ibanController = TextEditingController();

  void _savePayment() {
    // Lưu thông tin thanh toán ở đây (có thể là gọi API hoặc lưu vào SharedPreferences)
    print('Payment saved');
    // Sau khi lưu thành công, bạn có thể quay lại màn hình PaymentScreen:
    Navigator.pop(context);  // Quay lại màn hình trước (PaymentScreen)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: cardExpireController,
              decoration: InputDecoration(labelText: 'Card Expiry'),
            ),
            TextField(
              controller: cardNumberController,
              decoration: InputDecoration(labelText: 'Card Number'),
            ),
            TextField(
              controller: cardTypeController,
              decoration: InputDecoration(labelText: 'Card Type'),
            ),
            TextField(
              controller: currencyController,
              decoration: InputDecoration(labelText: 'Currency'),
            ),
            TextField(
              controller: ibanController,
              decoration: InputDecoration(labelText: 'IBAN'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePayment,
              child: Text('Save Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
