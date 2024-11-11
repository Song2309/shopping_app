import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'auth_service.dart';  // Import AuthService
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';  // Thêm thư viện SharedPreferences

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;  // Biến để theo dõi trạng thái loading

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = emailController.text;
    String password = passwordController.text;

    try {
      // Gọi API đăng nhập
      bool success = await AuthService().loginUser(email, password);

      setState(() {
        _isLoading = false;
      });

      // Kiểm tra nếu đăng nhập thành công
      if (success) {
        // Lưu email vào SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);

        // Điều hướng đến màn hình chính sau khi đăng nhập thành công
        Get.offAll(() => HomeScreen());  // Thay thế bằng màn hình chính của bạn
      } else {
        // Hiển thị thông báo nếu đăng nhập thất bại
        Get.snackbar(
          'Login Failed',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Hiển thị thông báo lỗi khi API gọi bị thất bại
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input email
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            // Input password
            TextField(
              controller: passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            // Forgot password link
            GestureDetector(
              onTap: () {
                // Điều hướng đến màn hình quên mật khẩu
                Get.to(() => ForgotPasswordScreen());
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            // Login button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin, // Disable button khi đang loading
              child: _isLoading
                  ? CircularProgressIndicator()  // Hiển thị loading khi đang xử lý
                  : Text('Login'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15),
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            // Sign up link
            TextButton(
              onPressed: () {
                // Điều hướng đến màn hình đăng ký
                Get.to(() => SignupScreen());
              },
              child: Text("Don't have an account? Sign Up"),
            ),
            SizedBox(height: 20),
            // Social login buttons (Apple, Facebook, Gmail)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialLoginButton(Icons.apple, Colors.black, "Apple"),
                SizedBox(width: 10),
                _buildSocialLoginButton(Icons.facebook, Colors.blue, "Facebook"),
                SizedBox(width: 10),
                _buildSocialLoginButton(Icons.email, Colors.red, "Gmail"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm tạo các nút đăng nhập xã hội (Apple, Facebook, Gmail)
  Widget _buildSocialLoginButton(IconData icon, Color color, String label) {
    return GestureDetector(
      onTap: () {
        // Thực hiện hành động đăng nhập với từng nền tảng ở đây
        print('$label login button clicked');
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: color,
        child: Icon(
          icon,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
