import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// Import your providers here
// import 'package:your_app/providers/cart_provider.dart';
// import 'package:your_app/providers/order_provider.dart';

class OrderPendingScreen extends StatefulWidget {
  final int orderId;
  final String? token; // Pass JWT token if your API requires auth header

  const OrderPendingScreen({
    Key? key,
    required this.orderId,
    this.token,
  }) : super(key: key);

  @override
  State<OrderPendingScreen> createState() => _OrderPendingScreenState();
}

class _OrderPendingScreenState extends State<OrderPendingScreen> {
  Timer? _pollingTimer;
  bool _isChecking = false;
  bool _isPaid = false;
  String _statusMessage = "We are processing your order confirmation.";

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    // Poll the status endpoint every 3 seconds
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkPaymentStatus();
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    final url = Uri.parse('http://YOUR_BACKEND_IP:16800/api/v1/payments/orders/${widget.orderId}/aba-khqr/status');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (widget.token != null) 'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract statusCode or statusMessage from response
        final statusCode = data['data']?['statusCode'];
        final statusMsg = data['data']?['statusMessage'];

        if (statusCode == '0' || statusMsg == 'APPROVED') {
          _pollingTimer?.cancel(); // Stop timer

          if (!mounted) return;

          setState(() {
            _isPaid = true;
            _statusMessage = "Payment confirmed! Thank you for your order.";
          });

          // 1. Refresh Cart Provider so Bottom Navbar badge updates to 0
          // Provider.of<CartProvider>(context, listen: false).fetchCart();

          // 2. Refresh Order Provider
          // Provider.of<OrderProvider>(context, listen: false).fetchOrderDetails(widget.orderId);
        }
      }
    } catch (e) {
      debugPrint("Error checking payment status: $e");
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Order Status'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container (Hourglass or Success Checkbox)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _isPaid ? Colors.green.shade50 : Colors.amber.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPaid ? Icons.check_circle_outline : Icons.hourglass_top_rounded,
                  size: 64,
                  color: _isPaid ? Colors.green : Colors.amber.shade800,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                _isPaid ? "Payment Successful!" : "Order Pending",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle / Status message
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),

              // Order Number
              Text(
                "Order #${widget.orderId}",
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 48),

              // Action Buttons
              if (!_isPaid)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                )
              else ...[
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to Main Shell / Root with Navbar visible
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF673AB7),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text(
                    "Continue Shopping",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}