import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:castpa/domain/entities/enums.dart';

class PublishResult {
  final Platform platform;
  final bool success;
  final String? error;

  const PublishResult({
    required this.platform,
    required this.success,
    this.error,
  });
}

class PublishService {
  // Returns a LinkedIn asset URN after registering + uploading one image file.
  Future<String?> _uploadLinkedInImage({
    required String accessToken,
    required String authorUrn,
    required String filePath,
  }) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      // ignore: avoid_print
      print('[Publish:LinkedIn] image not found at $filePath — skipping');
      return null;
    }

    // Step 1: register upload
    // ignore: avoid_print
    print('[Publish:LinkedIn] registering image upload for $filePath');
    final registerResponse = await http.post(
      Uri.parse('https://api.linkedin.com/v2/assets?action=registerUpload'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
        'X-Restli-Protocol-Version': '2.0.0',
      },
      body: jsonEncode({
        'registerUploadRequest': {
          'recipes': ['urn:li:digitalmediaRecipe:feedshare-image'],
          'owner': authorUrn,
          'serviceRelationships': [
            {
              'relationshipType': 'OWNER',
              'identifier': 'urn:li:userGeneratedContent',
            }
          ],
        }
      }),
    ).timeout(const Duration(seconds: 15));

    // ignore: avoid_print
    print('[Publish:LinkedIn] register status=${registerResponse.statusCode}  body=${registerResponse.body}');

    if (registerResponse.statusCode != 200) return null;

    final registerBody = jsonDecode(registerResponse.body) as Map<String, dynamic>;
    final value = registerBody['value'] as Map<String, dynamic>;
    final asset = value['asset'] as String;
    final uploadUrl = (value['uploadMechanism']
        ['com.linkedin.digitalmedia.uploading.MediaUploadHttpRequest']
        ['uploadUrl']) as String;

    // Step 2: upload the binary
    // ignore: avoid_print
    print('[Publish:LinkedIn] uploading image to $uploadUrl');
    final bytes = await file.readAsBytes();
    final uploadResponse = await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/octet-stream',
      },
      body: bytes,
    ).timeout(const Duration(seconds: 60));

    // ignore: avoid_print
    print('[Publish:LinkedIn] upload status=${uploadResponse.statusCode}');

    if (uploadResponse.statusCode != 201 && uploadResponse.statusCode != 200) {
      return null;
    }

    return asset;
  }

  Future<PublishResult> publishToLinkedIn({
    required String accessToken,
    required String content,
    List<String> mediaFilePaths = const [],
  }) async {
    if (accessToken.isEmpty) {
      return const PublishResult(
        platform: Platform.linkedin,
        success: false,
        error: 'Not connected to LinkedIn',
      );
    }

    // ignore: avoid_print
    print('[Publish:LinkedIn] starting — content length=${content.length}  images=${mediaFilePaths.length}');

    try {
      // Fetch author URN
      // ignore: avoid_print
      print('[Publish:LinkedIn] fetching user profile...');
      final profileResponse = await http.get(
        Uri.parse('https://api.linkedin.com/v2/userinfo'),
        headers: {'Authorization': 'Bearer $accessToken'},
      ).timeout(const Duration(seconds: 15));

      // ignore: avoid_print
      print('[Publish:LinkedIn] profile status=${profileResponse.statusCode}  body=${profileResponse.body}');

      if (profileResponse.statusCode != 200) {
        // ignore: avoid_print
        print('[Publish:LinkedIn] FAILED to get profile');
        return const PublishResult(
          platform: Platform.linkedin,
          success: false,
          error: 'Failed to get LinkedIn profile',
        );
      }

      final profile = jsonDecode(profileResponse.body) as Map<String, dynamic>;
      final urn = 'urn:li:person:${profile['sub']}';
      // ignore: avoid_print
      print('[Publish:LinkedIn] author urn=$urn');

      // Upload images and collect asset URNs
      final assetUrns = <String>[];
      for (final path in mediaFilePaths) {
        final asset = await _uploadLinkedInImage(
          accessToken: accessToken,
          authorUrn: urn,
          filePath: path,
        );
        if (asset != null) assetUrns.add(asset);
      }
      // ignore: avoid_print
      print('[Publish:LinkedIn] uploaded ${assetUrns.length}/${mediaFilePaths.length} images');

      // Build ugcPost body
      final Map<String, dynamic> shareContent;
      if (assetUrns.isEmpty) {
        shareContent = {
          'shareCommentary': {'text': content},
          'shareMediaCategory': 'NONE',
        };
      } else {
        shareContent = {
          'shareCommentary': {'text': content},
          'shareMediaCategory': 'IMAGE',
          'media': assetUrns.map((a) => {
            'status': 'READY',
            'media': a,
          }).toList(),
        };
      }

      // ignore: avoid_print
      print('[Publish:LinkedIn] posting ugcPost...');
      final response = await http.post(
        Uri.parse('https://api.linkedin.com/v2/ugcPosts'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'X-Restli-Protocol-Version': '2.0.0',
        },
        body: jsonEncode({
          'author': urn,
          'lifecycleState': 'PUBLISHED',
          'specificContent': {
            'com.linkedin.ugc.ShareContent': shareContent,
          },
          'visibility': {
            'com.linkedin.ugc.MemberNetworkVisibility': 'PUBLIC',
          },
        }),
      ).timeout(const Duration(seconds: 30));

      // ignore: avoid_print
      print('[Publish:LinkedIn] ugcPost status=${response.statusCode}  body=${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ignore: avoid_print
        print('[Publish:LinkedIn] SUCCESS');
        return const PublishResult(platform: Platform.linkedin, success: true);
      }
      // ignore: avoid_print
      print('[Publish:LinkedIn] FAILED — API error ${response.statusCode}');
      return PublishResult(
        platform: Platform.linkedin,
        success: false,
        error: 'LinkedIn API error: ${response.statusCode}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Publish:LinkedIn] EXCEPTION: $e');
      return PublishResult(
        platform: Platform.linkedin,
        success: false,
        error: 'Error: $e',
      );
    }
  }

  Future<PublishResult> publishToX({
    required String accessToken,
    required String content,
  }) async {
    if (accessToken.isEmpty) {
      return const PublishResult(
        platform: Platform.x,
        success: false,
        error: 'Not connected to X',
      );
    }

    // ignore: avoid_print
    print('[Publish:X] starting — content length=${content.length}');

    try {
      // ignore: avoid_print
      print('[Publish:X] posting tweet...');
      final response = await http.post(
        Uri.parse('https://api.twitter.com/2/tweets'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': content}),
      ).timeout(const Duration(seconds: 30));

      // ignore: avoid_print
      print('[Publish:X] status=${response.statusCode}  body=${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // ignore: avoid_print
        print('[Publish:X] SUCCESS');
        return const PublishResult(platform: Platform.x, success: true);
      }
      // ignore: avoid_print
      print('[Publish:X] FAILED — API error ${response.statusCode}');
      return PublishResult(
        platform: Platform.x,
        success: false,
        error: 'X API error: ${response.statusCode}',
      );
    } catch (e) {
      // ignore: avoid_print
      print('[Publish:X] EXCEPTION: $e');
      return PublishResult(
        platform: Platform.x,
        success: false,
        error: 'Error: $e',
      );
    }
  }

  Future<List<PublishResult>> publish({
    required List<Platform> targets,
    required String? linkedinContent,
    required String? twitterContent,
    required String? linkedinToken,
    required String? xToken,
    List<String> mediaFilePaths = const [],
  }) async {
    final results = <PublishResult>[];
    for (final target in targets) {
      switch (target) {
        case Platform.linkedin:
          results.add(await publishToLinkedIn(
            accessToken: linkedinToken ?? '',
            content: linkedinContent ?? '',
            mediaFilePaths: mediaFilePaths,
          ));
        case Platform.x:
          results.add(await publishToX(
            accessToken: xToken ?? '',
            content: twitterContent ?? '',
          ));
      }
    }
    return results;
  }
}
