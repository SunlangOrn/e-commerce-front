import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class KhqrCard extends StatefulWidget {
  final String merchantName;
  final double subtotal;
  final double total;
  final String currency;
  final Uint8List? qrBytes;
  final VoidCallback? onDownloadQr;
  final VoidCallback? onRefreshQr;
  final int durationInSeconds;

  const KhqrCard({
    super.key,
    required this.merchantName,
    required this.subtotal,
    required this.total,
    this.currency = "KHR",
    this.qrBytes,
    this.onDownloadQr,
    this.onRefreshQr,
    this.durationInSeconds = 300,
  });

  @override
  State<KhqrCard> createState() => _KhqrCardState();
}

class _KhqrCardState extends State<KhqrCard> {
  Timer? _timer;
  late int _remainingSeconds;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant KhqrCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.qrBytes != oldWidget.qrBytes && widget.qrBytes != null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _remainingSeconds = widget.durationInSeconds;
    _isExpired = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isExpired = true;
          });
        }
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }

  String _formatCurrency(double amount) {
    final whole = amount.round();
    final grouped = whole
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]},");
    return "$grouped ${widget.currency}";
  }

  @override
  Widget build(BuildContext context) {
    final hasQr = widget.qrBytes != null && widget.qrBytes!.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (hasQr)
                        ColorFiltered(
                          colorFilter: _isExpired
                              ? const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          )
                              : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                          child: Opacity(
                            opacity: _isExpired ? 0.2 : 1.0,
                            child: Image.memory(
                              widget.qrBytes!,
                              width: 280,
                              fit: BoxFit.contain,
                              gaplessPlayback: true,
                            ),
                          ),
                        )
                      else
                        const SizedBox(
                          height: 280,
                          width: 280,
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      if (_isExpired)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_off_outlined, size: 48, color: Colors.redAccent),
                            const SizedBox(height: 8),
                            const Text(
                              "QR Code Expired",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: widget.onRefreshQr,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text("Regenerate QR"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),
                _AmountRow(label: "Subtotal", value: _formatCurrency(widget.subtotal)),
                const SizedBox(height: 6),
                _AmountRow(
                  label: "Total Amount",
                  value: _formatCurrency(widget.total),
                  bold: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 320,
          child: Column(
            children: [
              OutlinedButton.icon(
                onPressed: _isExpired ? null : widget.onDownloadQr,
                icon: const Icon(Icons.file_download_outlined, size: 20),
                label: const Text("Download QR Code"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: _isExpired ? Colors.grey.shade300 : const Color(0xFF0284C7),
                  ),
                  foregroundColor: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _isExpired ? Colors.red.shade50 : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_isExpired) ...[
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
                        "Waiting for payment (${_formatTimer(_remainingSeconds)})",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ] else ...[
                      Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                      const SizedBox(width: 6),
                      Text(
                        "Session expired",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ],
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