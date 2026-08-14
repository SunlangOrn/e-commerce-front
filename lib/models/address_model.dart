class AddressModel {
  final int id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String city;
  final String? province;
  final String? postalCode;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? googlePlaceId;

  AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    required this.city,
    this.province,
    this.postalCode,
    required this.isDefault,
    this.latitude,
    this.longitude,
    this.googlePlaceId,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
    id: json["id"],
    fullName: json["fullName"] ?? "",
    phone: json["phone"] ?? "",
    addressLine: json["addressLine"] ?? "",
    city: json["city"] ?? "",
    province: json["province"],
    postalCode: json["postalCode"],
    isDefault: json["isDefault"] ?? false,
    latitude: (json["latitude"] as num?)?.toDouble(),
    longitude: (json["longitude"] as num?)?.toDouble(),
    googlePlaceId: json["googlePlaceId"],
  );

  Map<String, dynamic> toRequestJson() => {
    "fullName": fullName,
    "phone": phone,
    "addressLine": addressLine,
    "city": city,
    "province": province,
    "postalCode": postalCode,
    "isDefault": isDefault,
    "latitude": latitude,
    "longitude": longitude,
    "googlePlaceId": googlePlaceId,
  };
}