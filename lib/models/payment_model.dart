class AbaPayWayResponseModel {
  final int orderId;
  final String? tranId;
  final double amount;
  final String currency;
  final String? qrString;
  final String? qrImage; // may be raw base64 OR a data:image/png;base64,... URI
  final String? abaPayDeeplink;
  final String? statusCode;
  final String? statusMessage;
  final String? expiresAt;

  AbaPayWayResponseModel({
    required this.orderId,
    this.tranId,
    required this.amount,
    required this.currency,
    this.qrString,
    this.qrImage,
    this.abaPayDeeplink,
    this.statusCode,
    this.statusMessage,
    this.expiresAt,
  });

  /// Strips a "data:image/png;base64," prefix if present, so
  /// base64Decode always gets clean base64.
  String? get qrImageRaw {
    if (qrImage == null || qrImage!.isEmpty) return null;
    final commaIndex = qrImage!.indexOf(',');
    if (qrImage!.startsWith('data:') && commaIndex != -1) {
      return qrImage!.substring(commaIndex + 1);
    }
    return qrImage;
  }

  factory AbaPayWayResponseModel.fromJson(Map<String, dynamic> json) =>
      AbaPayWayResponseModel(
        orderId: json["orderId"],
        tranId: json["tranId"],
        amount: (json["amount"] as num?)?.toDouble() ?? 0.0,
        currency: json["currency"] ?? "KHR",
        qrString: json["qrString"],
        qrImage: json["qrImage"],
        abaPayDeeplink: json["abaPayDeeplink"],
        statusCode: json["statusCode"],
        statusMessage: json["statusMessage"],
        expiresAt: json["expiresAt"],
      );

  bool get isSuccess => statusCode == "0";
}