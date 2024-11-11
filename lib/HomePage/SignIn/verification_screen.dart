import 'package:flutter/material.dart';
import 'package:get/get.dart';  // Dùng để điều hướng
import 'forgot_password_screen.dart';  // Nếu cần điều hướng quay lại ForgotPasswordScreen
import 'change_password.dart';  // Màn hình thay đổi mật khẩu sau khi xác thực thành công

class VerificationScreen extends StatefulWidget {
  final String email; // Truyền email từ màn hình ForgotPasswordScreen sang

  VerificationScreen({required this.email});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController verificationController = TextEditingController();
  bool _isLoading = false;  // Biến trạng thái loading
  final String correctCode = '123456';  // Mã xác thực giả để so sánh

  void verifyCode() async {
    setState(() {
      _isLoading = true;  // Bật trạng thái loading khi bắt đầu xác thực
    });

    await Future.delayed(Duration(seconds: 2));  // Giả lập thời gian xử lý

    if (verificationController.text == correctCode) {
      // Mã xác thực đúng
      setState(() {
        _isLoading = false;  // Tắt loading
      });
      Get.to(() => ChangePasswordScreen(email: widget.email));  // Điều hướng đến màn hình đổi mật khẩu
    } else {
      // Mã xác thực sai
      setState(() {
        _isLoading = false;  // Tắt loading
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid verification code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verification Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Input for verification code
            TextField(
              controller: verificationController,
              keyboardType: TextInputType.number,
              maxLength: 6,  // Giới hạn số chữ số nhập vào
              decoration: InputDecoration(
                labelText: 'Enter 6-digit verification code',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Verify Button
            ElevatedButton(
              onPressed: _isLoading ? null : verifyCode,  // Disable button when loading
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)  // Show loading indicator
                  : Text('Verify Code'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            // Resend Code Button (Optionally, you can add the functionality for this)
            TextButton(
              onPressed: () {
                // Logic to resend verification code
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Verification code sent again")),
                );
              },
              child: Text('Resend code'),
            ),
            SizedBox(height: 20),
            // Go back to Forgot Password screen
            TextButton(
              onPressed: () {
                Get.back();  // Quay lại màn hình Forgot Password
              },
              child: Text('Back to Forgot Password'),
            ),
          ],
        ),
      ),
    );
  }
}
