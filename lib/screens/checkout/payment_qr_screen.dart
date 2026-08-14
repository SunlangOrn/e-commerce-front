import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/api_constants.dart';
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
  bool _expired = false;
  bool _paymentCompleted = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      final orderId = orderProvider.currentOrder?.id;
      if (orderId == null) return;

      orderProvider.startPolling(
        orderId,
        onPaid: () {
          if (!mounted) return;
          _paymentCompleted = true;
          context.read<CartProvider>().fetchCart();
          context.read<ProductProvider>().fetchProducts();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => OrderResultScreen(order: orderProvider.currentOrder!),
            ),
          );
        },
        onExpired: () {
          _cancelPendingOrder();
          if (mounted) setState(() => _expired = true);
        },
      );
    });
  }

  @override
  void dispose() {
    context.read<OrderProvider>().stopPolling();
    super.dispose();
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
    await context.read<CartProvider>().fetchCart();
    await context.read<ProductProvider>().fetchProducts();
  }

  Future<void> _leavePayment() async {
    await _cancelPendingOrder();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (_) => false,
    );
  }

  Future<void> _downloadQr(String base64Image) async {
    try {
      final bytes = base64Decode(base64Image);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/khqr_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'ABA KHQR',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Couldn't prepare QR for download")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final qr = orderProvider.currentQr;
    final order = orderProvider.currentOrder;
    final qrRaw = qr?.qrImageRaw;

    return WillPopScope(
      onWillPop: () async {
        await _leavePayment();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Scan to pay with any banking app"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _leavePayment,
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_expired)
                  Column(
                    children: const [
                      Icon(Icons.timer_off, size: 64, color: Colors.orange),
                      SizedBox(height: 12),
                      Text("QR code expired"),
                    ],
                  )
                else
                  KhqrCard(
                    merchantName: ApiConstants.merchantName,
                    subtotal: order?.totalAmount ?? 0,
                    total: order?.totalAmount ?? 0,
                    qrImageBase64: qrRaw,
                  ),
                const SizedBox(height: 16),
                if (!_expired && qrRaw != null)
                  TextButton.icon(
                    onPressed: () => _downloadQr(qrRaw),
                    icon: const Icon(Icons.download_outlined),
                    label: const Text("Download QR"),
                  ),
                const SizedBox(height: 8),
                if (!_expired)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text("Waiting for payment..."),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
