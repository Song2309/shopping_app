import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';  // Điều hướng về LoginScreen sau khi đăng ký thành công

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isLoading = false;  // Trạng thái loading khi đang xử lý đăng ký

  Future<void> signupUser() async {
    if (passwordController.text != confirmPasswordController.text) {
      // Kiểm tra mật khẩu và xác nhận mật khẩu có khớp không
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() {
      _isLoading = true;  // Bật loading khi gửi yêu cầu đăng ký
    });

    final response = await http.post(
      Uri.parse('https://dummyjson.com/users/add'), // API đăng ký người dùng (thay đổi theo API của bạn)
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'fullName': fullNameController.text,
        'email': emailController.text,
        'password': passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false;  // Tắt loading khi đã nhận phản hồi từ API
    });

    if (response.statusCode == 200) {
      // Đăng ký thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Successful")),
      );
      // Điều hướng về màn hình đăng nhập
      Get.to(() => LoginScreen());
    } else {
      // Đăng ký thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Họ tên
            TextField(
              controller: fullNameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Mật khẩu
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Xác nhận mật khẩu
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Nút đăng ký
            ElevatedButton(
              onPressed: _isLoading ? null : signupUser,  // Disable nút khi đang xử lý
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)  // Hiển thị loading khi đang xử lý
                  : Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 10),
            // Đã có tài khoản? Quay lại login
            TextButton(
              onPressed: () {
                // Điều hướng quay lại màn hình đăng nhập
                Get.back();
              },
              child: Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
