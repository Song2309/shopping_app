import 'dart:async';  // Để sử dụng Timer
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late PageController _pageController;  // Quản lý các trang ảnh trong PageView
  bool _showButton = false;  // Để kiểm tra xem nút "Shopping Now" có hiển thị hay không
  int _currentPage = 0;  // Biến để lưu giữ trang hiện tại trong PageView

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Sau 3 giây, chuyển ảnh thứ 1 sang ảnh thứ 2
    Timer(Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        _pageController.animateToPage(1, duration: Duration(seconds: 1), curve: Curves.ease);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Hàm sẽ được gọi khi lướt tới ảnh
  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      // Hiển thị nút "Shopping Now" khi lướt đến ảnh thứ 4 (index 3)
      if (_currentPage == 3) {
        _showButton = true;
      } else {
        _showButton = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // PageView để lướt qua các ảnh
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,  // Xử lý khi thay đổi trang
              children: [
                // Bức ảnh đầu tiên, chỉ hiển thị trong 3 giây, rồi chuyển sang bức ảnh thứ 2
                Image.network(
                  'https://www.vietnamworks.com/hrinsider/wp-content/uploads/2023/12/hinh-nen-dep-cho-dien-thoai-voi-hinh-anh-thien-nhien-phong-cach-truyen-tranh.jpg',
                  fit: BoxFit.cover,
                ),
                Image.network(
                  'https://mega.com.vn/media/news/2802_hinh-nen-do-an-tren-dien-thoai-sieu-xinh43.jpg',
                  fit: BoxFit.cover,
                ),
                Image.network(
                  'https://mega.com.vn/media/news/2802_hinh-nen-do-an-tren-dien-thoai-sieu-xinh44.jpg',
                  fit: BoxFit.cover,
                ),
                Image.network(
                  'https://mega.com.vn/media/news/2802_hinh-nen-do-an-tren-dien-thoai-sieu-xinh31.jpg',
                  fit: BoxFit.cover,
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Chỉ báo chấm (dots) sẽ xuất hiện khi trang là 2 hoặc hơn (Bắt đầu từ ảnh thứ 2)
          if (_currentPage >= 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                // Bỏ qua chấm tròn cho ảnh đầu tiên (index 0)
                if (index == 0) return SizedBox.shrink();  // Không hiển thị chấm tròn cho ảnh đầu tiên

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

          SizedBox(height: 30),
          // Hiển thị nút "Shopping Now" khi lướt đến ảnh thứ 4
          if (_showButton)
            ElevatedButton(
              onPressed: () {
                // Điều hướng đến màn hình đăng nhập
                Get.to(() => LoginScreen());
              },
              child: Text("Shopping Now"),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(15),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
