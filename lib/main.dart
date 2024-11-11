// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'auth_controller.dart';
import 'HomePage/home_screen.dart';
import 'HomePage/SignIn/welcome_screen.dart';


void main() async {
  await GetStorage.init();  // Khởi tạo GetStorage
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AuthCheck(),  // Kiểm tra trạng thái đăng nhập
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    // Kiểm tra trạng thái đăng nhập và điều hướng tương ứng
    return Obx(() {
      if (authController.isLoggedIn.value) {
        return HomeScreen();  // Nếu đã đăng nhập, chuyển sang HomeScreen
      } else {
        return WelcomeScreen();  // Nếu chưa đăng nhập, hiển thị màn hình Welcome
      }
    });
  }
}
