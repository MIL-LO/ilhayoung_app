// lib/core/models/oauth_response.dart

class OAuthResponse {
  final bool success;
  final String? message;
  final String? accessToken;
  final String? refreshToken;

  OAuthResponse({
    required this.success,
    this.message,
    this.accessToken,
    this.refreshToken,
  });

  // 편의 속성들
  bool get hasAccessToken => accessToken != null && accessToken!.isNotEmpty;
  bool get hasRefreshToken => refreshToken != null && refreshToken!.isNotEmpty;

  factory OAuthResponse.fromJson(Map<String, dynamic> json) {
    return OAuthResponse(
      success: json['success'] ?? false,
      message: json['message'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  @override
  String toString() {
    return 'OAuthResponse(success: $success, message: $message, hasAccessToken: $hasAccessToken, hasRefreshToken: $hasRefreshToken)';
  }
}