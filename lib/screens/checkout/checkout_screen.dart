import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/address_card.dart';
import '../../widgets/primary_button.dart';
import '../address/address_list_screen.dart';
import 'payment_method_screen.dart';
import 'payment_qr_screen.dart';
import 'order_result_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  AddressModel? _selectedAddress;
  String _paymentMethod = "ABA_PAYWAY_KHQR";
  final _noteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final addressProvider = context.read<AddressProvider>();
      await addressProvider.fetchAddresses();
      if (mounted) {
        setState(() => _selectedAddress = addressProvider.defaultAddress ??
            (addressProvider.addresses.isNotEmpty ? addressProvider.addresses.first : null));
      }
    });
  }

  Future<void> _pickAddress() async {
    final picked = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddressListScreen(selectMode: true)),
    );
    if (picked != null) setState(() => _selectedAddress = picked);
  }

  Future<void> _choosePaymentMethod() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => PaymentMethodScreen(selected: _paymentMethod)),
    );
    if (result != null) setState(() => _paymentMethod = result);
  }

  Future<void> _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select a delivery address")));
      return;
    }

    final orderProvider = context.read<OrderProvider>();
    final ok = await orderProvider.checkout(
      addressId: _selectedAddress!.id,
      paymentMethod: _paymentMethod,
      note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(orderProvider.errorMessage ?? "Checkout failed")));
      return;
    }

    context.read<CartProvider>().fetchCart();

    if (_paymentMethod == "ABA_PAYWAY_KHQR" && orderProvider.currentQr != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PaymentQrScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderResultScreen(order: orderProvider.currentOrder!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>().cart;
    final orderProvider = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(onPressed: _pickAddress, child: const Text("Change")),
            ],
          ),
          if (_selectedAddress != null)
            AddressCard(address: _selectedAddress!)
          else
            OutlinedButton.icon(
              onPressed: _pickAddress,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text("Add / select an address"),
            ),
          const SizedBox(height: 24),
          const Text("Payment Method", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              _paymentMethod == "ABA_PAYWAY_KHQR"
                  ? Icons.qr_code
                  : Icons.local_shipping_outlined,
            ),
            title: Text(
              _paymentMethod == "ABA_PAYWAY_KHQR" ? "ABA KHQR" : "Cash on Delivery",
            ),
            trailing: TextButton(
              onPressed: _choosePaymentMethod,
              child: const Text("Change"),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: "Note (optional)",
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total", style: TextStyle(fontSize: 16)),
              Text(
                "\$${cart.total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: "Place Order",
            isLoading: orderProvider.isCheckingOut,
            onPressed: _placeOrder,
          ),
        ],
      ),
    );
  }
}