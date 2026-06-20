import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/data/services/gemini_service.dart';

class SaveStatusIndicator extends ConsumerStatefulWidget {
  final SaveState saveState;

  const SaveStatusIndicator({super.key, required this.saveState});

  @override
  ConsumerState<SaveStatusIndicator> createState() => _SaveStatusIndicatorState();
}

class _SaveStatusIndicatorState extends ConsumerState<SaveStatusIndicator> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _onTap() async {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inSeconds > 3) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;

    if (_tapCount >= 10) {
      _tapCount = 0;
      await _copyDebugData();
    }
  }

  Future<void> _copyDebugData() async {
    final editState = ref.read(postEditProvider);
    final post = editState.post;
    final settings = ref.read(settingsNotifierProvider).valueOrNull;
    final trendingAsync = ref.read(latestTrendingProvider);
    final trending = trendingAsync.valueOrNull;

    final trendTags = trending?.trendTopics
        .map((t) => t.replaceAll(' ', '_'))
        .toList() ?? [];
    final selectedTrend = editState.selectedTrendTags;
    final unselectedTrend = trendTags.where((t) => !selectedTrend.contains(t)).toList();

    const hookType = 'auto';
    const structure = 'auto';
    const endWithQuestion = 'auto';
    final postTagMode = settings?.postTagMode ?? 'range';
    final postTagMin = settings?.postTagMin ?? 3;
    final postTagMax = settings?.postTagMax ?? 10;
    final postTagExact = settings?.postTagExact ?? 5;

    final forLinkedIn = post.selectedPlatforms.any((p) => p.key == 'linkedin');
    final forX = post.selectedPlatforms.any((p) => p.key == 'x');

    final systemPrompt = GeminiService.buildPolishPrompt(
      dump: post.dump,
      forLinkedIn: forLinkedIn,
      forX: forX,
      hookType: hookType,
      structure: structure,
      endWithQuestion: endWithQuestion,
      postTagMode: postTagMode,
      postTagMin: postTagMin,
      postTagMax: postTagMax,
      postTagExact: postTagExact,
    );

    final debugData = {
      'dump': post.dump,
      'links': post.links,
      'platforms': post.selectedPlatforms.map((p) => p.key).toList(),
      'category': post.categoryId,
      'media': post.mediaIds,
      'linkedinContent': post.linkedinContent ?? '',
      'xContent': post.twitterContent ?? '',
      'postBaseTags': post.postBaseTags,
      'trendingTags': {
        'ragSuggested': editState.ragSuggestedTags.toList(),
        'userAdded': post.userAddedTrendTags,
        'selected': selectedTrend.toList(),
        'unselected': unselectedTrend,
      },
      'polishConfig': {
        'hookType': hookType,
        'structure': structure,
        'endWithQuestion': endWithQuestion,
        'postTagMode': postTagMode,
        'postTagMin': postTagMin,
        'postTagMax': postTagMax,
        'postTagExact': postTagExact,
      },
      'systemPrompt': systemPrompt,
    };

    await Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(debugData)));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full post data copied for debugging')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: switch (widget.saveState) {
          SaveState.saving => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 6),
                Text('Saving…', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          SaveState.saved => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, size: 14, color: Colors.green),
                SizedBox(width: 4),
                Text('Saved', style: TextStyle(fontSize: 12, color: Colors.green)),
              ],
            ),
          SaveState.error => const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 14, color: Colors.red),
                SizedBox(width: 4),
                Text('Error', style: TextStyle(fontSize: 12, color: Colors.red)),
              ],
            ),
          SaveState.idle => const SizedBox.shrink(),
          SaveState.deleted => const SizedBox.shrink(),
        },
      ),
    );
  }
}
