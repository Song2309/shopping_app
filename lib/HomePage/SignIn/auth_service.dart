import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String apiUrl = "https://dummyjson.com/users";  // URL API giả lập

  // Hàm đăng nhập
  Future<bool> loginUser(String email, String password) async {
    try {
      // Gửi yêu cầu GET tới API để lấy danh sách người dùng
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Giải mã JSON từ phản hồi API
        final data = json.decode(response.body);

        // Kiểm tra người dùng có email và mật khẩu hợp lệ
        final users = data['users'];
        for (var user in users) {
          if (user['email'] == email && user['password'] == password) {
            return true; // Đăng nhập thành công
          }
        }
        return false; // Đăng nhập thất bại
      } else {
        // Trường hợp có lỗi từ server
        print('Server error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
}
