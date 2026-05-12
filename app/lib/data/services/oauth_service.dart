import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

// Register this exact URL in LinkedIn and X developer portals.
// flutter_web_auth_2 intercepts this HTTPS redirect directly on Android
// via a custom tab redirect — no GitHub JS bounce needed.
const _redirectUri = 'https://faisal-kursheedali.github.io/castpa-auth/';
const _callbackScheme = 'castpa';

class OAuthTokens {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;

  const OAuthTokens({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
  });
}

class OAuthService {
  static String _randomString(int bytes) =>
      base64UrlEncode(List.generate(bytes, (_) => Random.secure().nextInt(256)))
          .replaceAll('=', '');

  static String _s256(String verifier) =>
      base64UrlEncode(sha256.convert(utf8.encode(verifier)).bytes)
          .replaceAll('=', '');

  Future<OAuthTokens> connectLinkedIn({
    required String clientId,
    required String clientSecret,
  }) async {
    final state = _randomString(16);

    final authUrl = Uri.https('www.linkedin.com', '/oauth/v2/authorization', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': _redirectUri,
      'state': state,
      'scope': 'openid profile w_member_social',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: _callbackScheme,
    );

    // ignore: avoid_print
    print('[OAuth:LinkedIn] result=$result');

    final uri = Uri.parse(result);
    final params = uri.queryParameters;

    if (params['error'] != null) {
      throw Exception('LinkedIn denied: ${params['error_description'] ?? params['error']}');
    }
    if (params['state'] != state) {
      throw Exception('OAuth state mismatch');
    }
    final code = params['code'] ?? (throw Exception('No code in redirect. Params: $params'));

    final res = await http.post(
      Uri.https('www.linkedin.com', '/oauth/v2/accessToken'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': _redirectUri,
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Token exchange failed (${res.statusCode}): ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final expiresIn = json['expires_in'] as int?;
    final expiresAt = expiresIn != null ? DateTime.now().add(Duration(seconds: expiresIn)) : null;

    // ignore: avoid_print
    print('[OAuth:LinkedIn] token exchange SUCCESS');
    // ignore: avoid_print
    print('[OAuth:LinkedIn] access_token=${json['access_token']}');
    // ignore: avoid_print
    print('[OAuth:LinkedIn] refresh_token=${json['refresh_token']}');
    // ignore: avoid_print
    print('[OAuth:LinkedIn] expires_in=${expiresIn}s  expires_at=$expiresAt');

    return OAuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: expiresAt,
    );
  }

  Future<OAuthTokens> connectX({
    required String clientId,
    String? clientSecret,
  }) async {
    // ignore: avoid_print
    print('[OAuth:X] starting — clientId=$clientId  hasSecret=${clientSecret != null && clientSecret.isNotEmpty}');

    final verifier = _randomString(32);
    final challenge = _s256(verifier);
    final state = _randomString(16);

    final authUrl = Uri.https('twitter.com', '/i/oauth2/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'redirect_uri': _redirectUri,
      'scope': 'tweet.read tweet.write users.read offline.access',
      'state': state,
      'code_challenge': challenge,
      'code_challenge_method': 'S256',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: _callbackScheme,
    );

    // ignore: avoid_print
    print('[OAuth:X] result=$result');

    final uri = Uri.parse(result);
    final params = uri.queryParameters;

    if (params['error'] != null) {
      throw Exception('X denied: ${params['error_description'] ?? params['error']}');
    }
    if (params['state'] != state) {
      throw Exception('OAuth state mismatch');
    }
    final code = params['code'] ?? (throw Exception('No code in redirect. Params: $params'));

    // ignore: avoid_print
    print('[OAuth:X] code=$code');
    // ignore: avoid_print
    print('[OAuth:X] redirect_uri=$_redirectUri');

    final credentials = base64Encode(utf8.encode('$clientId:${clientSecret ?? ''}'));
    // ignore: avoid_print
    print('[OAuth:X] posting token exchange...');

    final http.Response res;
    try {
      res = await http.post(
        Uri.https('api.twitter.com', '/2/oauth2/token'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Basic $credentials',
        },
        body: {
          'grant_type': 'authorization_code',
          'code': code,
          'redirect_uri': _redirectUri,
          'code_verifier': verifier,
        },
      ).timeout(const Duration(seconds: 30));
    } catch (e) {
      // ignore: avoid_print
      print('[OAuth:X] token exchange EXCEPTION: $e');
      rethrow;
    }

    // ignore: avoid_print
    print('[OAuth:X] token exchange status=${res.statusCode}  body=${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Token exchange failed (${res.statusCode}): ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final expiresIn = json['expires_in'] as int?;
    final expiresAt = expiresIn != null ? DateTime.now().add(Duration(seconds: expiresIn)) : null;

    // ignore: avoid_print
    print('[OAuth:X] token exchange SUCCESS');
    // ignore: avoid_print
    print('[OAuth:X] access_token=${json['access_token']}');
    // ignore: avoid_print
    print('[OAuth:X] refresh_token=${json['refresh_token']}');
    // ignore: avoid_print
    print('[OAuth:X] expires_in=${expiresIn}s  expires_at=$expiresAt');

    return OAuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: expiresAt,
    );
  }
}
