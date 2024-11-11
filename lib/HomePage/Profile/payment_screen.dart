import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'add_payment_screen.dart'; // Import AddPaymentScreen
import 'address_screen.dart'; // Import AddressScreen

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isLoading = true;
  String cardExpire = '';
  String cardNumber = '';
  String cardType = '';
  String currency = '';
  String iban = '';

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  // Hàm lấy thông tin thanh toán từ API
  Future<void> _loadPaymentInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');  // Lấy email từ SharedPreferences

    if (email != null && email.isNotEmpty) {
      try {
        final paymentData = await fetchPaymentData();  // Lấy dữ liệu thanh toán từ API
        final payment = paymentData.firstWhere(
              (payment) => payment['email'] == email,
          orElse: () => {},
        );

        if (payment.isNotEmpty) {
          setState(() {
            cardExpire = payment['bank']['cardExpire'] ?? 'No expiration date';
            cardNumber = payment['bank']['cardNumber'] ?? 'No card number';
            cardType = payment['bank']['cardType'] ?? 'No card type';
            currency = payment['bank']['currency'] ?? 'No currency';
            iban = payment['bank']['iban'] ?? 'No IBAN';
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
          print('Payment data not found');
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching payment data: $e");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      print('No email found in SharedPreferences');
    }
  }

  // Fetch payment data from the API
  Future<List<Map<String, dynamic>>> fetchPaymentData() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/users'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['users']);
    } else {
      throw Exception('Failed to load payment data');
    }
  }



  // Hàm để điều hướng đến màn hình thêm phương thức thanh toán
  void _addPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddPaymentScreen()),  // Điều hướng đến AddPaymentScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Method'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())  // Hiển thị loading khi dữ liệu đang tải
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tạo khung cho thông tin thanh toán và thêm sự kiện nhấn để chuyển tới AddressScreen
            GestureDetector(
                // Khi nhấn vào khung này sẽ điều hướng đến AddressScreen
              child: Container(
                padding: EdgeInsets.all(16),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Expiry: $cardExpire', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Card Number: $cardNumber', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Card Type: $cardType', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('Currency: $currency', style: TextStyle(fontSize: 18)),
                    SizedBox(height: 10),
                    Text('IBAN: $iban', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _addPayment,  // Nút để thêm phương thức thanh toán mới
              child: Text('Add Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}
