import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../widgets/primary_button.dart';
import '../home/main_navigation_screen.dart';

class OrderResultScreen extends StatelessWidget {
  final OrderModel order;
  const OrderResultScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    // Correctly checks payment status and order status variations
    final isPaid = order.paymentStatus == "SUCCESS" ||
        order.paymentStatus == "PAID" ||
        order.status == "COMPLETED" ||
        order.status == "PROCESSING" ||
        order.paymentMethod == "CASH_ON_DELIVERY";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPaid ? Icons.check_circle : Icons.hourglass_top,
                  size: 56,
                  color: isPaid ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isPaid ? "Payment Successful" : "Order Pending",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                isPaid
                    ? "Thank you! Order confirmation details were sent to your email."
                    : "We are processing your order confirmation.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              Text(
                "Order #${order.orderNumber}",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
              const SizedBox(height: 40),
              OutlinedButton(
                onPressed: () {
                  // Export or download receipt feature
                },
                child: const Text("Download Receipt"),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: "Continue Shopping",
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                      (route) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}