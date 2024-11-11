import 'package:flutter/material.dart';

class VoucherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voucher'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chọn Voucher giảm giá:', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            VoucherCard(discount: 20),
            SizedBox(height: 20),
            VoucherCard(discount: 30),
            SizedBox(height: 20),
            VoucherCard(discount: 50),
          ],
        ),
      ),
    );
  }
}

class VoucherCard extends StatelessWidget {
  final int discount;

  const VoucherCard({Key? key, required this.discount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Giảm $discount%',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Xử lý khi voucher được áp dụng
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voucher $discount% đã được áp dụng!')),
                );
              },
              child: Text('Áp dụng'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
