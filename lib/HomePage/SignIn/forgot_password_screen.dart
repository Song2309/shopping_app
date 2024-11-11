import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'verification_screen.dart';  // Điều hướng đến màn hình nhập mã xác thực

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  void sendVerificationCode() {
    // Gửi mã xác nhận tới email (giả lập gửi mã)
    // Ở đây, bạn có thể thay bằng API gửi mã thật
    Get.snackbar(
      'Verification Code Sent',
      'A verification code has been sent to your email.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Sau khi gửi mã xác thực, điều hướng đến màn hình nhập mã xác thực
    Get.to(() => VerificationScreen(email: emailController.text));  // Truyền email sang màn hình VerificationScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Enter your email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendVerificationCode,  // Gọi hàm sendVerificationCode khi nhấn nút
              child: Text('Send Verification Code'),
            ),
          ],
        ),
      ),
    );
  }
}
