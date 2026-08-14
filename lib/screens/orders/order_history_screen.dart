import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case "DELIVERED":
        return Colors.green;
      case "CANCELLED":
        return Colors.red;
      case "SHIPPED":
      case "PROCESSING":
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: provider.isLoadingHistory
          ? const Center(child: CircularProgressIndicator())
          : provider.orderHistory.isEmpty
          ? const Center(child: Text("No orders yet"))
          : RefreshIndicator(
        onRefresh: () => provider.fetchOrders(),
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: provider.orderHistory.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final order = provider.orderHistory[index];
            return Card(
              child: ListTile(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailScreen(orderId: order.id),
                  ),
                ),
                title: Text("Order #${order.orderNumber}"),
                subtitle: Text(
                  "${order.totalItems} items · \$${order.totalAmount.toStringAsFixed(2)}",
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    // Fixed: Used .withOpacity instead of .withValues
                    color: _statusColor(order.orderStatus)
                        .withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.orderStatus,
                    style: TextStyle(
                      color: _statusColor(order.orderStatus),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}