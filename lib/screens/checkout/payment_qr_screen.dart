import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/api_constants.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/khqr_card.dart';
import '../home/main_navigation_screen.dart';
import 'order_result_screen.dart';

class PaymentQrScreen extends StatefulWidget {
  const PaymentQrScreen({super.key});

  @override
  State<PaymentQrScreen> createState() => _PaymentQrScreenState();
}

class _PaymentQrScreenState extends State<PaymentQrScreen> {
  bool _paymentCompleted = false;
  bool _leaving = false;

  // Memoization cache to prevent QR image flicker during polling
  String? _cachedRawQr;
  Uint8List? _cachedQrBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPolling();
    });
  }

  void _startPolling() {
    final orderProvider = context.read<OrderProvider>();
    final orderId = orderProvider.currentOrder?.id;
    if (orderId == null) return;

    orderProvider.startPolling(
      orderId,
      onPaid: () async {
        if (!mounted || _leaving) return;
        _paymentCompleted = true;
        _leaving = true;

        // 1. Stop polling timer immediately
        orderProvider.stopPolling();

        // 2. Refresh Cart & Products so Bottom Navbar badge drops to 0
        try {
          await context.read<CartProvider>().fetchCart();
          if (mounted) {
            await context.read<ProductProvider>().fetchProducts();
          }
        } catch (e) {
          debugPrint("Error updating background cart state: $e");
        }

        if (!mounted) return;

        // 3. Fetch latest order state with safety fallback
        OrderModel? updatedOrder;
        try {
          updatedOrder = await orderProvider.fetchOrderDetail(orderId);
        } catch (e) {
          debugPrint("Failed to fetch fresh order details: $e");
        }

        final baseOrder = updatedOrder ?? orderProvider.currentOrder;

        if (baseOrder == null) return;

        // 4. Trust the real backend values (paymentStatus, orderStatus, paidAt)
        // from the fresh fetch. Only fall back to a hardcoded guess if the
        // fetch itself failed right after the poll succeeded.
        final finalOrder = updatedOrder != null
            ? baseOrder
            : baseOrder.copyWith(
          paymentStatus: "SUCCESS",
          orderStatus: "PROCESSING",
        );

        if (!mounted) return;

        // 5. Navigate to Order Result Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderResultScreen(
              order: finalOrder,
            ),
          ),
        );
      },
      onExpired: () {
        if (!mounted || _leaving) return;
        _cancelPendingOrder();
      },
    );
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopPolling();
    super.dispose();
  }

  /// Decode Base64 ONLY when raw string changes
  Uint8List? _getOrDecodeQrBytes(String? raw) {
    if (raw == null || raw.isEmpty) {
      _cachedRawQr = null;
      _cachedQrBytes = null;
      return null;
    }

    if (raw == _cachedRawQr && _cachedQrBytes != null) {
      return _cachedQrBytes;
    }

    _cachedRawQr = raw;
    final cleanBase64 = raw.contains(',') ? raw.split(',').last : raw;
    try {
      _cachedQrBytes = base64Decode(cleanBase64);
    } catch (_) {
      _cachedQrBytes = null;
    }
    return _cachedQrBytes;
  }

  Future<void> _cancelPendingOrder() async {
    if (_paymentCompleted || _leaving) return;
    _leaving = true;

    final orderProvider = context.read<OrderProvider>();
    final orderId = orderProvider.currentOrder?.id;
    orderProvider.stopPolling();

    if (orderId != null) {
      await orderProvider.cancelOrder(orderId);
    }

    if (!mounted) return;
    context.read<CartProvider>().fetchCart();
    context.read<ProductProvider>().fetchProducts();
  }

  Future<void> _leavePayment() async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await _cancelPendingOrder();
    if (!mounted) return;

    // Returns home while preserving the BottomNavigationBar
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          (_) => false,
    );
  }

  Future<void> _handleRefresh() async {
    if (_leaving) return;

    final orderProvider = context.read<OrderProvider>();
    final orderId = orderProvider.currentOrder?.id;
    if (orderId == null) return;

    final ok = await orderProvider.regenerateAbaKhqr(orderId);

    if (!mounted || _leaving) return;

    if (ok) {
      _startPolling();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? "Failed to regenerate QR"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _downloadQr(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/khqr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ABA KHQR Payment',
      );
    } catch (_) {
      if (mounted && !_leaving) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't prepare QR for download"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final qr = orderProvider.currentQr;
    final order = orderProvider.currentOrder;
    final qrRaw = qr?.qrImageRaw;

    final qrBytes = _getOrDecodeQrBytes(qrRaw);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _leavePayment();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text("Scan to pay with any banking app"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leavePayment,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: KhqrCard(
              merchantName: ApiConstants.merchantName,
              subtotal: order?.totalAmount ?? 0,
              total: order?.totalAmount ?? 0,
              qrBytes: qrBytes,
              onDownloadQr: qrBytes != null ? () => _downloadQr(qrBytes) : null,
              onRefreshQr: _handleRefresh,
            ),
          ),
        ),
      ),
    );
  }
}