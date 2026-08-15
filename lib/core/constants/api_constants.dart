import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  ApiConstants._();

  static const String _emulatorHost = "10.0.2.2"; // Needed for your simulator
  static const String _webHost = "localhost";
  static const String _realDevice = "192.168.1.3";

  static const int _port = 16800;

  static String get _host {
    if (kIsWeb) {
      return _webHost;
    } else if (Platform.isAndroid) {
      return _emulatorHost;
    } else if (Platform.isIOS) {
      return "localhost";
    }
    return _realDevice;
  }

  static String get rootUrl => "http://$_host:$_port";
  static String get baseUrl => "$rootUrl/api/v1";

  static const String signup = "/auth/signup";
  static const String signin = "/auth/signin";
  static const String refresh = "/auth/refresh";
  static const String logout = "/auth/logout";
  static const String me = "/auth/me";
  static const String updateProfile = "/auth/profile";

  static const String categories = "/categories";
  static String categoryById(int id) => "/categories/$id";

  static const String products = "/products";
  static String productById(int id) => "/products/$id";

  static const String myCart = "/carts/mycart";
  static const String cartItems = "/carts/items";
  static String cartItemById(int itemId) => "/carts/items/$itemId";
  static const String clearCart = "/carts";

  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith("http")) return path;
    return "$rootUrl$path";
  }

  static const String addresses = "/addresses";
  static String addressById(int id) => "/addresses/$id";
  static String addressSetDefault(int id) => "/addresses/$id/default";

  static const String orders = "/orders";
  static const String checkout = "/orders/checkout";
  static String orderById(int id) => "/orders/$id";
  static String orderCancel(int id) => "/orders/$id/cancel";

  static String createAbaKhqr(int orderId) => "/payments/orders/$orderId/aba-khqr";
  static String checkAbaKhqr(int orderId) => "/payments/orders/$orderId/aba-khqr/status";
  static const String merchantName = "Your Shop Name";
  static const String currency = "KHR";

  static const String uploadProfileImage = "/file-uploads/users/me/profile-image";

  static const String abaLogoAsset = "assets/aba/ABA BANK.png";
}
