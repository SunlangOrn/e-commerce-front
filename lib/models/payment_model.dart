class AbaPayWayResponseModel {
  final int orderId;
  final String? tranId;
  final double amount;
  final String currency;
  final String? qrString;
  final String? qrImage;
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

  /// Strips data URI prefixes if present to return clean base64 string
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
        orderId: json["orderId"] ?? 0,
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