import 'dart:async';
import 'package:flutter/material.dart';
import '../core/services/order_service.dart';
import '../core/services/payment_service.dart';
import '../models/order_model.dart';
import '../models/payment_model.dart';

class OrderProvider extends ChangeNotifier {
  final _orderService = OrderService();
  final _paymentService = PaymentService();

  bool isCheckingOut = false;
  String? errorMessage;

  OrderModel? currentOrder;
  AbaPayWayResponseModel? currentQr;

  bool isPolling = false;
  Timer? _pollTimer;

  List<OrderModel> orderHistory = [];
  bool isLoadingHistory = false;

  Future<bool> checkout({
    required int addressId,
    required String paymentMethod,
    String? note,
  }) async {
    isCheckingOut = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentOrder = await _orderService.checkout(
        addressId: addressId,
        paymentMethod: paymentMethod,
        note: note,
      );
      currentQr = currentOrder?.abaPayWayResponse;
      isCheckingOut = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = _extractError(e);
      isCheckingOut = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> regenerateAbaKhqr(int orderId) async {
    try {
      errorMessage = null;
      currentQr = await _paymentService.createAbaKhqr(orderId);
      currentOrder = await _orderService.getById(orderId);
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = "Failed to create payment QR";
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchOrders() async {
    isLoadingHistory = true;
    notifyListeners();
    try {
      orderHistory = await _orderService.list();
    } catch (_) {
      errorMessage = "Failed to load orders";
    }
    isLoadingHistory = false;
    notifyListeners();
  }

  Future<OrderModel?> fetchOrderDetail(int id) async {
    try {
      final order = await _orderService.getById(id);
      currentOrder = order;      // ADDED — keep provider state in sync
      notifyListeners();         // ADDED — so watchers rebuild
      return order;
    } catch (_) {
      errorMessage = "Failed to load order";
      notifyListeners();
      return null;
    }
  }

  Future<bool> cancelOrder(int id) async {
    try {
      final updated = await _orderService.cancel(id);
      final index = orderHistory.indexWhere((o) => o.id == id);
      if (index != -1) orderHistory[index] = updated;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = "Failed to cancel order";
      notifyListeners();
      return false;
    }
  }

  void startPolling(
      int orderId, {
        required VoidCallback onPaid,
        required VoidCallback onExpired,
        int intervalSeconds = 3,
        int timeoutSeconds = 900,
      }) {
    stopPolling();
    isPolling = true;
    int elapsed = 0;

    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      elapsed += intervalSeconds;
      try {
        final status = await _paymentService.checkAbaKhqr(orderId);

        // Preserve base64 image data when updating status response
        if (currentQr != null) {
          currentQr = AbaPayWayResponseModel(
            orderId: status.orderId,
            tranId: status.tranId ?? currentQr?.tranId,
            amount: status.amount > 0 ? status.amount : (currentQr?.amount ?? 0.0),
            currency: status.currency,
            qrString: status.qrString ?? currentQr?.qrString,
            qrImage: status.qrImage ?? currentQr?.qrImage,
            abaPayDeeplink: status.abaPayDeeplink ?? currentQr?.abaPayDeeplink,
            statusCode: status.statusCode,
            statusMessage: status.statusMessage,
            expiresAt: status.expiresAt ?? currentQr?.expiresAt,
          );
        } else {
          currentQr = status;
        }

        notifyListeners();

        if (status.isSuccess) {
          stopPolling();
          onPaid();
        } else if (elapsed >= timeoutSeconds) {
          stopPolling();
          onExpired();
        }
      } catch (_) {
        if (elapsed >= timeoutSeconds) {
          stopPolling();
          onExpired();
        }
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    isPolling = false;
  }

  String _extractError(Object e) {
    try {
      final data = (e as dynamic).response?.data;
      if (data != null && data["message"] != null) return data["message"];
    } catch (_) {}
    return "Checkout failed. Please try again.";
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}