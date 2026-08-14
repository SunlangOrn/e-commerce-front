import 'dart:convert';
import 'package:flutter/material.dart';

class KhqrCard extends StatelessWidget {
  final String merchantName;
  final double subtotal;
  final double total;
  final String currency;
  final String? qrImageBase64;
  final VoidCallback? onDownloadQr;

  const KhqrCard({
    super.key,
    required this.merchantName,
    required this.subtotal,
    required this.total,
    this.currency = "KHR",
    required this.qrImageBase64,
    this.onDownloadQr,
  });

  String _formatCurrency(double amount) {
    final whole = amount.round();
    final grouped = whole
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]},");
    return "$grouped $currency";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- ABA Pre-Rendered KHQR Card Container ---
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Display ABA's Base64 image directly without adding competing borders
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: qrImageBase64 != null && qrImageBase64!.isNotEmpty
                      ? Image.memory(
                    base64Decode(qrImageBase64!),
                    width: 280,
                    fit: BoxFit.contain,
                  )
                      : const SizedBox(
                    height: 320,
                    width: 280,
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),

                // Subtotal & Total Breakdown below the official QR
                _AmountRow(label: "Subtotal", value: _formatCurrency(subtotal)),
                const SizedBox(height: 6),
                _AmountRow(
                  label: "Total Amount",
                  value: _formatCurrency(total),
                  bold: true,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // --- Action Area: Download & Live Status Indicator ---
        SizedBox(
          width: 320,
          child: Column(
            children: [
              // Download Button
              OutlinedButton.icon(
                onPressed: onDownloadQr,
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text("Download QR Code"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF0284C7)),
                  foregroundColor: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 12),

              // Animated "Waiting for payment..." Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Waiting for payment...",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _AmountRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 15 : 13,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      color: bold ? const Color(0xFF0F172A) : Colors.grey.shade600,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}