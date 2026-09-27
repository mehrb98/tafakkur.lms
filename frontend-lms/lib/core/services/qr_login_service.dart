import '../api/api_client.dart';

/// The browser that is asking to be signed in, as reported by `POST /auth/qr/scan`.
class QrLoginDevice {
  const QrLoginDevice({required this.deviceName, this.ipAddress, required this.requestedAt});

  factory QrLoginDevice.fromJson(Map<String, dynamic> json) => QrLoginDevice(
    deviceName: json['device_name'] as String? ?? 'Unknown browser',
    ipAddress: json['ip_address'] as String?,
    requestedAt: DateTime.parse(json['requested_at'] as String).toLocal(),
  );

  final String deviceName;
  final String? ipAddress;
  final DateTime requestedAt;
}

/// Approves Telegram-style QR sign-ins shown on the web app.
class QrLoginService {
  QrLoginService(this.api);

  final ApiClient api;

  /// Extracts the token from a scanned `tafakkur://qr-login?token=...` code,
  /// or returns null when the code is something else.
  static String? parseToken(String? raw) {
    if (raw == null) return null;
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'tafakkur' || uri.host != 'qr-login') return null;
    final token = uri.queryParameters['token'];
    return token == null || token.isEmpty ? null : token;
  }

  Future<QrLoginDevice> scan(String token) async {
    final body = await api.post('/auth/qr/scan', {'qr_token': token}, true) as Map<String, dynamic>;
    return QrLoginDevice.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> approve(String token) => api.post('/auth/qr/approve', {'qr_token': token}, true);

  Future<void> decline(String token) => api.post('/auth/qr/decline', {'qr_token': token}, true);
}
