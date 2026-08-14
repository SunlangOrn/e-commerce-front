import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../widgets/primary_button.dart';
import '../checkout/payment_qr_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderModel? _order;
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final order = await context.read<OrderProvider>().fetchOrderDetail(widget.orderId);
    setState(() {
      _order = order;
      _loading = false;
    });
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    final ok = await context.read<OrderProvider>().cancelOrder(widget.orderId);
    setState(() => _cancelling = false);
    if (ok) await _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? "Order cancelled" : "Failed to cancel")),
      );
    }
  }

  Future<void> _resumePayment() async {
    final orderProvider = context.read<OrderProvider>();
    final regenerated = await orderProvider.regenerateAbaKhqr(widget.orderId);
    if (regenerated && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaymentQrScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to regenerate QR code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = _order;
    final canCancel = order != null &&
        (order.orderStatus == "PENDING" || order.orderStatus == "PROCESSING");
    final canResumePayment = order != null &&
        order.paymentMethod == "ABA_PAYWAY_KHQR" &&
        order.paymentStatus == "PENDING" &&
        order.orderStatus != "CANCELLED";

    return Scaffold(
      appBar: AppBar(title: Text(order != null ? "Order #${order.orderNumber}" : "Order")),
      body: _loading || order == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Status: ${order.orderStatus}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Payment: ${order.paymentStatus}"),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(item.productName),
            subtitle: Text("x${item.quantity}"),
            trailing: Text("\$${item.subtotal.toStringAsFixed(2)}"),
          )),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                "\$${order.totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (canResumePayment)
            PrimaryButton(label: "Resume Payment", onPressed: _resumePayment),
          if (canCancel) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _cancelling ? null : _cancel,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: _cancelling
                  ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text("Cancel Order"),
            ),
          ],
        ],
      ),
    );
  }
}