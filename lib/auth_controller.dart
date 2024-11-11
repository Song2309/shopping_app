// auth_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  // Sử dụng GetStorage để lưu trữ trạng thái đăng nhập
  final box = GetStorage();

  var isLoggedIn = false.obs;  // Trạng thái đăng nhập

  @override
  void onInit() {
    super.onInit();
    // Kiểm tra trạng thái đăng nhập khi khởi động app
    isLoggedIn.value = box.read('isLoggedIn') ?? false;
  }

  void login() {
    // Sau khi login thành công, lưu trạng thái vào GetStorage
    box.write('isLoggedIn', true);
    isLoggedIn.value = true;
  }

  void logout() {
    // Khi logout, xóa trạng thái đăng nhập
    box.remove('isLoggedIn');
    isLoggedIn.value = false;
  }
}
