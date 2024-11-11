import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CartController extends GetxController {
  var cartItems = <Map<String, dynamic>>[].obs;  // Giỏ hàng sẽ được theo dõi ở đây
  final GetStorage _box = GetStorage();  // Dùng GetStorage để lưu giỏ hàng

  @override
  void onInit() {
    super.onInit();
    // Lấy giỏ hàng đã lưu từ GetStorage khi controller được khởi tạo
    List<Map<String, dynamic>> savedCart = _box.read('cart') ?? [];
    cartItems.assignAll(savedCart);
  }

  // Kiểm tra xem sản phẩm có trong giỏ hàng hay không
  bool _isProductInCart(int productId) {
    return cartItems.any((item) => item['id'] == productId);
  }

  // Thêm sản phẩm vào giỏ hàng
  void addProductToCart(Map<String, dynamic> productData, int quantity) {
    if (quantity <= 0) {
      // Nếu quantity là số âm hoặc 0 thì không thêm
      return;
    }

    var existingProduct = cartItems.firstWhere(
          (item) => item['id'] == productData['id'],
      orElse: () => {},
    );

    if (existingProduct.isEmpty) {
      // Nếu sản phẩm chưa có trong giỏ hàng, thêm mới
      cartItems.add({
        'id': productData['id'],
        'title': productData['title'],
        'price': productData['price'],
        'quantity': quantity,
        'image': productData['images'][0],  // Lấy hình ảnh đầu tiên của sản phẩm
      });
    } else {
      // Nếu sản phẩm đã có trong giỏ hàng, cập nhật số lượng
      existingProduct['quantity'] += quantity;
    }

    // Sau khi thay đổi giỏ hàng, lưu lại vào GetStorage
    _box.write('cart', cartItems.toList());
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void removeProductFromCart(int productId) {
    cartItems.removeWhere((item) => item['id'] == productId);
    // Sau khi thay đổi giỏ hàng, lưu lại vào GetStorage
    _box.write('cart', cartItems.toList());
  }

  // Lấy tổng giá trị giỏ hàng, đảm bảo trả về kiểu double
  double get totalPrice {
    return cartItems.fold(0.0, (sum, item) {
      double price = item['price']?.toDouble() ?? 0.0;  // Đảm bảo price là double
      double quantity = item['quantity']?.toDouble() ?? 0.0;  // Đảm bảo quantity là double
      return sum + (price * quantity);  // Tính tổng giá trị giỏ hàng
    });
  }

  // Kiểm tra nếu giỏ hàng có rỗng hay không
  bool get isCartEmpty {
    return cartItems.isEmpty;
  }

  // Lưu giỏ hàng vào GetStorage sau mỗi lần thay đổi
  void saveCart() {
    _box.write('cart', cartItems.toList());
  }

  // Tải lại giỏ hàng từ GetStorage khi cần
  void loadCart() {
    List<Map<String, dynamic>> savedCart = _box.read('cart') ?? [];
    cartItems.assignAll(savedCart);
  }
}
