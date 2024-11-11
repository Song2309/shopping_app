import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'home_screen.dart';

class CheckInfoScreen extends StatefulWidget {
  final String email; // Nhận email đã đăng nhập từ bên ngoài (ví dụ: từ trang đăng nhập)

  CheckInfoScreen({required this.email});

  @override
  _CheckInfoScreenState createState() => _CheckInfoScreenState();
}

class _CheckInfoScreenState extends State<CheckInfoScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  // Các biến lưu trữ thông tin người dùng và thanh toán
  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';
  String address = '';
  String city = '';
  String paymentCardNumber = '';
  String paymentCardExpire = '';
  String paymentCardType = '';

  // Biến để xử lý trạng thái loading
  bool isLoading = true;

  // Quản lý TextEditingController
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController cardNumberController;
  late TextEditingController cardExpireController;
  late TextEditingController cardTypeController;

  @override
  void initState() {
    super.initState();
    email = widget.email;  // Sử dụng email đã truyền vào
    _fetchUserData();  // Gọi API để lấy thông tin người dùng

    // Khởi tạo các TextEditingController với dữ liệu ban đầu
    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);
    emailController = TextEditingController(text: email);
    phoneController = TextEditingController(text: phone);
    addressController = TextEditingController(text: address);
    cityController = TextEditingController(text: city);
    cardNumberController = TextEditingController(text: paymentCardNumber);
    cardExpireController = TextEditingController(text: paymentCardExpire);
    cardTypeController = TextEditingController(text: paymentCardType);
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên khi không còn sử dụng các controller
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    cardNumberController.dispose();
    cardExpireController.dispose();
    cardTypeController.dispose();
    super.dispose();
  }

  // Hàm gọi API để lấy thông tin người dùng theo email
  Future<void> _fetchUserData() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/users'));

    if (response.statusCode == 200) {
      // Nếu API trả về dữ liệu thành công
      final data = json.decode(response.body);
      // Tìm người dùng dựa trên email
      var user = data['users'].firstWhere(
            (user) => user['email'] == email,
        orElse: () => null,
      );

      if (user != null) {
        setState(() {
          firstName = user['firstName'] ?? 'No first name';
          lastName = user['lastName'] ?? 'No last name';
          phone = user['phone'] ?? 'No phone';
          address = user['address']['address'] ?? 'No address';
          city = user['address']['city'] ?? 'No city';
          paymentCardNumber = user['bank']['cardNumber'] ?? 'No card number';
          paymentCardExpire = user['bank']['cardExpire'] ?? 'No card expire date';
          paymentCardType = user['bank']['cardType'] ?? 'No card type';
          isLoading = false;  // Đổi trạng thái khi đã tải xong
        });

        // Cập nhật giá trị các controller với dữ liệu mới
        firstNameController.text = firstName;
        lastNameController.text = lastName;
        phoneController.text = phone;
        addressController.text = address;
        cityController.text = city;
        cardNumberController.text = paymentCardNumber;
        cardExpireController.text = paymentCardExpire;
        cardTypeController.text = paymentCardType;
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      // Nếu có lỗi khi gọi API
      setState(() {
        isLoading = false;
      });
    }
  }

  // Hàm điều hướng qua các bước
  void _nextPage(int index) {
    if (_currentPage < 2) {
      _pageController.animateToPage(index, duration: Duration(seconds: 1), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Check Info")),
      body: Column(
        children: [
          // 3 ô điều hướng với animation
          Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return GestureDetector(
                  onTap: () => _pageController.animateToPage(index, duration: Duration(seconds: 1), curve: Curves.ease),
                  child: Container(
                    width: 12,
                    height: 12,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.blue
                          : Colors.black.withOpacity(0.4),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Trang hiển thị các bước
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                // Bước 1: Hiển thị thông tin người dùng từ API hoặc nhập thủ công
                _buildUserInfoStep(),

                // Bước 2: Hiển thị thông tin thanh toán từ API hoặc nhập thủ công
                _buildPaymentInfoStep(),

                // Bước 3: Xác nhận đơn hàng
                _buildOrderCompletedStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bước 1: Hiển thị thông tin người dùng từ API hoặc nhập thủ công
  Widget _buildUserInfoStep() {
    return isLoading
        ? Center(child: CircularProgressIndicator())  // Hiển thị loading khi đang tải dữ liệu
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("User Information", style: TextStyle(fontSize: 20)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField("First Name", firstNameController),
              _buildTextField("Last Name", lastNameController),
              _buildTextField("Email", emailController),
              _buildTextField("Phone", phoneController),
              _buildTextField("Address", addressController),
              _buildTextField("City", cityController),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => _nextPage(1),
          child: Text("Next"),
        ),
      ],
    );
  }

  // Bước 2: Hiển thị thông tin thanh toán từ API hoặc nhập thủ công
  Widget _buildPaymentInfoStep() {
    return isLoading
        ? Center(child: CircularProgressIndicator())  // Hiển thị loading khi đang tải dữ liệu
        : Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Payment Information", style: TextStyle(fontSize: 20)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildTextField("Card Number", cardNumberController),
              _buildTextField("Card Expiry", cardExpireController),
              _buildTextField("Card Type", cardTypeController),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () => _nextPage(2),
          child: Text("Next"),
        ),
      ],
    );
  }

  // Bước 3: Xác nhận đơn hàng
  Widget _buildOrderCompletedStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Order Completed", style: TextStyle(fontSize: 24)),
        SizedBox(height: 50),
        Image.network(
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtnga3oDJmwyLWlUUID2afCvIXN4bZO8MGxECKryPVVLMEnGveoihOn3zY6BT3wIlnmBQ&usqp=CAU',
          height: 200,
          width: 200,
          fit: BoxFit.cover,
        ),
        SizedBox(height: 50),
        ElevatedButton(
          onPressed: () {
            Get.to(HomeScreen());
          },
          child: Text("Go to Home", style: TextStyle(fontSize: 20)),
        )
      ],
    );
  }

  // Hàm để tạo TextField dễ sử dụng hơn
  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
