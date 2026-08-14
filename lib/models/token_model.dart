class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String? refreshTokenExpiresAt;
  final String? tokenType;

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    this.refreshTokenExpiresAt,
    this.tokenType,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    accessToken: json["accessToken"],
    refreshToken: json["refreshToken"],
    refreshTokenExpiresAt: json["refreshTokenExpiresAt"],
    tokenType: json["tokenType"],
  );
}