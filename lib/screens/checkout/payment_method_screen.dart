import 'package:flutter/material.dart';
import '../../core/constants/api_constants.dart';

class PaymentMethodScreen extends StatelessWidget {
  final String selected;
  const PaymentMethodScreen({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose way to pay")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PaymentMethodTile(
            iconAsset: ApiConstants.abaLogoAsset,
            title: "ABA KHQR",
            subtitle: "Scan to pay with any banking app",
            enabled: true,
            selected: selected == "ABA_PAYWAY_KHQR",
            onTap: () => Navigator.pop(context, "ABA_PAYWAY_KHQR"),
          ),
          _PaymentMethodTile(
            icon: Icons.local_shipping_outlined,
            title: "Cash on Delivery",
            subtitle: "Pay when your order arrives",
            enabled: true,
            selected: selected == "CASH_ON_DELIVERY",
            onTap: () => Navigator.pop(context, "CASH_ON_DELIVERY"),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String? iconAsset;
  final IconData? icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final bool selected;
  final VoidCallback? onTap;

  const _PaymentMethodTile({
    this.iconAsset,
    this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          enabled: enabled,
          onTap: enabled ? onTap : null,
          leading: iconAsset != null
              ? Image.asset(iconAsset!, width: 32, height: 32,
              errorBuilder: (_, __, ___) => const Icon(Icons.qr_code))
              : Icon(icon, size: 28),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
          trailing: enabled ? const Icon(Icons.chevron_right) : null,
        ),
      ),
    );
  }
}