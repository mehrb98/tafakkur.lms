import 'dart:convert';

import 'package:http/http.dart' as http;

/// Rails API base URL. Override with `--dart-define=API_URL=...`
/// (the Android emulator reaches the host at 10.0.2.2).
const apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://localhost:3001/api/v1');

class ApiException implements Exception {
  ApiException(this.status, this.code, this.message);

  final int status;
  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Thin JSON client for the Rails API. Holds the access token in memory and the
/// refresh token taken from the `refresh_token` Set-Cookie header, and retries
/// once after refreshing when a request returns 401.
class ApiClient {
  ApiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;
  String? accessToken;
  String? _refreshCookie;

  void Function()? onSessionExpired;

  Uri _uri(String path, [Map<String, Object?> query = const {}]) {
    final params = <String, String>{
      for (final entry in query.entries)
        if (entry.value != null && entry.value.toString().isNotEmpty) entry.key: entry.value.toString(),
    };
    return Uri.parse('$apiUrl$path').replace(queryParameters: params.isEmpty ? null : params);
  }

  Map<String, String> _headers({bool json = false}) => {
    'Accept': 'application/json',
    if (json) 'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    if (_refreshCookie != null) 'Cookie': 'refresh_token=$_refreshCookie',
  };

  void _captureRefreshCookie(http.Response response) {
    final header = response.headers['set-cookie'];
    final match = header == null ? null : RegExp(r'refresh_token=([^;]+)').firstMatch(header);
    if (match != null) _refreshCookie = match.group(1);
  }

  dynamic _decode(http.Response response) {
    _captureRefreshCookie(response);
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final error = body is Map<String, dynamic> ? body['error'] as Map<String, dynamic>? : null;
    throw ApiException(
      response.statusCode,
      error?['code'] as String? ?? 'http_error',
      error?['message'] as String? ?? 'Request failed (${response.statusCode})',
    );
  }

  /// POST. Pass [retry] for authenticated calls that should refresh once on 401.
  Future<dynamic> post(String path, [Map<String, Object?>? body, bool retry = false]) {
    return _send(
      () => _http.post(_uri(path), headers: _headers(json: true), body: jsonEncode(body ?? {})),
      retry: retry,
    );
  }

  Future<dynamic> get(String path, [Map<String, Object?> query = const {}]) {
    return _send(() => _http.get(_uri(path, query), headers: _headers()), retry: true);
  }

  Future<dynamic> _send(Future<http.Response> Function() request, {required bool retry}) async {
    try {
      return _decode(await request());
    } on ApiException catch (error) {
      if (!retry || error.status != 401) rethrow;
      if (!await refresh()) {
        onSessionExpired?.call();
        rethrow;
      }
      return _decode(await request());
    }
  }

  Future<bool> refresh() async {
    if (_refreshCookie == null) return false;
    try {
      final body = await post('/auth/refresh') as Map<String, dynamic>;
      accessToken = (body['data'] as Map<String, dynamic>)['access_token'] as String;
      return true;
    } on Exception {
      return false;
    }
  }

  void clear() {
    accessToken = null;
    _refreshCookie = null;
  }
}
