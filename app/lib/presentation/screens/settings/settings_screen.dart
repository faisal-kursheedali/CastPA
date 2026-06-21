import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:castpa/application/providers/database_provider.dart';
import 'package:castpa/application/providers/repository_providers.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/application/providers/bootstrap_provider.dart';
import 'package:castpa/data/database/app_database.dart';
import 'package:castpa/data/services/bootstrap_service.dart';
import 'package:castpa/data/services/oauth_service.dart';
import 'package:castpa/domain/entities/app_settings.dart';
import 'package:castpa/domain/entities/device.dart' as domain;

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // AI
  late TextEditingController _geminiCtrl;
  late TextEditingController _genModelCtrl;
  late TextEditingController _embedModelCtrl;
  bool _aiUnlocked = false;
  int _aiTapCount = 0;
  DateTime? _lastAiTap;

  // LinkedIn
  late TextEditingController _linkedInClientIdCtrl;
  late TextEditingController _linkedInClientSecretCtrl;
  bool _linkedInUnlocked = false;
  int _linkedInTapCount = 0;
  DateTime? _lastLinkedInTap;
  bool _isConnectingLinkedIn = false;

  // X
  late TextEditingController _xClientIdCtrl;
  late TextEditingController _xClientSecretCtrl;
  bool _xUnlocked = false;
  int _xTapCount = 0;
  DateTime? _lastXTap;
  bool _isConnectingX = false;

  // Publishing
  late TextEditingController _publishPerWeekCtrl;

  // Trending
  late TextEditingController _trendFetchCountCtrl;
  late TextEditingController _trendTagsPerPostCtrl;

  // Post
  late TextEditingController _postTagMinCtrl;
  late TextEditingController _postTagMaxCtrl;
  late TextEditingController _postTagExactCtrl;

  // Unlink
  int _unlinkTapCount = 0;
  DateTime? _lastUnlinkTap;

  // Version tap
  int _versionTapCount = 0;
  DateTime? _lastVersionTap;

  bool _initialized = false;
  final _oauth = OAuthService();

  @override
  void initState() {
    super.initState();
    _geminiCtrl = TextEditingController();
    _genModelCtrl = TextEditingController();
    _embedModelCtrl = TextEditingController();
    _linkedInClientIdCtrl = TextEditingController();
    _linkedInClientSecretCtrl = TextEditingController();
    _xClientIdCtrl = TextEditingController();
    _xClientSecretCtrl = TextEditingController();
    _publishPerWeekCtrl = TextEditingController();
    _trendFetchCountCtrl = TextEditingController();
    _trendTagsPerPostCtrl = TextEditingController();
    _postTagMinCtrl = TextEditingController();
    _postTagMaxCtrl = TextEditingController();
    _postTagExactCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _geminiCtrl.dispose();
    _genModelCtrl.dispose();
    _embedModelCtrl.dispose();
    _linkedInClientIdCtrl.dispose();
    _linkedInClientSecretCtrl.dispose();
    _xClientIdCtrl.dispose();
    _xClientSecretCtrl.dispose();
    _publishPerWeekCtrl.dispose();
    _trendFetchCountCtrl.dispose();
    _trendTagsPerPostCtrl.dispose();
    _postTagMinCtrl.dispose();
    _postTagMaxCtrl.dispose();
    _postTagExactCtrl.dispose();
    super.dispose();
  }

  // ── 5-tap unlock helper ───────────────────────────────────────────────────

  void _registerTap({
    required int count,
    required DateTime? lastTap,
    required void Function(int, DateTime) onUpdate,
    required VoidCallback onUnlock,
  }) {
    final now = DateTime.now();
    int c =
        (lastTap != null &&
            now.difference(lastTap) > const Duration(seconds: 3))
        ? 0
        : count;
    c++;
    if (c >= 5) {
      c = 0;
      onUnlock();
    }
    onUpdate(c, now);
  }

  // ── Save handlers ─────────────────────────────────────────────────────────

  Future<void> _saveAi(AppSettings current) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(
          current.copyWith(
            geminiToken: _geminiCtrl.text.trim(),
            genModel: _genModelCtrl.text.trim(),
            embedModel: _embedModelCtrl.text.trim(),
          ),
        );
    if (mounted) {
      setState(() => _aiUnlocked = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AI settings saved')));
    }
  }

  Future<void> _saveLinkedInCredentials(AppSettings current) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(
          current.copyWith(
            linkedinClientId: _linkedInClientIdCtrl.text.trim(),
            linkedinClientSecret: _linkedInClientSecretCtrl.text.trim(),
          ),
        );
    if (mounted) {
      setState(() => _linkedInUnlocked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LinkedIn app credentials saved')),
      );
    }
  }

  Future<void> _saveXCredentials(AppSettings current) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(
          current.copyWith(
            xClientId: _xClientIdCtrl.text.trim(),
            xClientSecret: _xClientSecretCtrl.text.trim(),
          ),
        );
    if (mounted) {
      setState(() => _xUnlocked = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('X app credentials saved')));
    }
  }

  Future<void> _savePublishPerWeek(AppSettings current) async {
    final val = int.tryParse(_publishPerWeekCtrl.text) ?? 3;
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(current.copyWith(publishPerWeek: val));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  Future<void> _savePostSettings(AppSettings current) async {
    final min = int.tryParse(_postTagMinCtrl.text) ?? 3;
    final max = int.tryParse(_postTagMaxCtrl.text) ?? 10;
    final exact = int.tryParse(_postTagExactCtrl.text) ?? 5;
    if (current.postTagMode == 'range' && max <= min) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Max must be greater than Min')),
      );
      return;
    }
    await ref.read(settingsNotifierProvider.notifier).save(
      current.copyWith(postTagMin: min, postTagMax: max, postTagExact: exact),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  Future<void> _saveTrendingSettings(AppSettings current) async {
    final fetchCount = int.tryParse(_trendFetchCountCtrl.text) ?? 7;
    final tagsPerPost = int.tryParse(_trendTagsPerPostCtrl.text) ?? 5;
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(current.copyWith(trendFetchCount: fetchCount, trendTagsPerPost: tagsPerPost));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  // ── OAuth connect ─────────────────────────────────────────────────────────

  Future<void> _connectLinkedIn(AppSettings settings) async {
    setState(() => _isConnectingLinkedIn = true);
    try {
      final tokens = await _oauth.connectLinkedIn(
        clientId: settings.linkedinClientId!,
        clientSecret: settings.linkedinClientSecret!,
      );
      await ref
          .read(settingsNotifierProvider.notifier)
          .save(
            settings.copyWith(
              linkedinAuthToken: tokens.accessToken,
              linkedinRefreshToken: tokens.refreshToken,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('LinkedIn connected')));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[OAuth:LinkedIn] _connectLinkedIn caught error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to LinkedIn: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isConnectingLinkedIn = false);
    }
  }

  Future<void> _disconnectLinkedIn(AppSettings settings) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(settings.copyWith(clearLinkedin: true));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('LinkedIn disconnected')));
    }
  }

  Future<void> _connectX(AppSettings settings) async {
    setState(() => _isConnectingX = true);
    try {
      final tokens = await _oauth.connectX(
        clientId: settings.xClientId!,
        clientSecret: settings.xClientSecret,
      );
      await ref
          .read(settingsNotifierProvider.notifier)
          .save(
            settings.copyWith(
              xAuthToken: tokens.accessToken,
              xRefreshToken: tokens.refreshToken,
            ),
          );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('X connected')));
      }
    } catch (e) {
      // ignore: avoid_print
      print('[OAuth:X] _connectX caught error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isConnectingX = false);
    }
  }

  Future<void> _disconnectX(AppSettings settings) async {
    await ref
        .read(settingsNotifierProvider.notifier)
        .save(settings.copyWith(clearX: true));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('X disconnected')));
    }
  }

  Future<void> _logDebugState(String tag) async {
    // ignore: avoid_print
    print('[$tag] ── DEBUG STATE ──────────────────────────────');

    // SharedPreferences dump
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    // ignore: avoid_print
    print('[$tag] SharedPreferences (${keys.length} keys):');
    for (final k in keys) {
      // ignore: avoid_print
      print('[$tag]   $k = ${prefs.get(k)}');
    }

    // Devices table dump
    final devices = await ref.read(deviceRepositoryProvider).getAllDevices();
    // ignore: avoid_print
    print('[$tag] devices table (${devices.length} rows):');
    for (final d in devices) {
      // ignore: avoid_print
      print('[$tag]   id=${d.deviceId}  name=${d.deviceName}  path="${d.rootFolderPath}"');
    }

    // ignore: avoid_print
    print('[$tag] ─────────────────────────────────────────────');
  }

  Future<void> _unlinkDevice() async {
    await _logDebugState('UNLINK:before');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Unlink Device'),
        content: const Text(
          'This will remove the sync folder from this device. '
          'The app will close and you will need to choose a folder on next launch.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final bootstrapService = ref.read(bootstrapServiceProvider);
    final config = ref.read(bootstrapConfigProvider).valueOrNull;

    // 1. The DB lives directly in the sync folder. On unlink, copy it to the
    //    sandboxed app-documents location so the app still has data afterwards.
    if (config?.syncFolderPath != null && config!.syncFolderPath!.isNotEmpty) {
      final syncDbPath = '${config.syncFolderPath}/castpa.db';
      final appDbPath = await bootstrapService.dbPath(); // app documents fallback
      if (File(syncDbPath).existsSync() && syncDbPath != appDbPath) {
        // ignore: avoid_print
        print('[UNLINK] preserving castpa.db → $appDbPath');
        await File(syncDbPath).copy(appDbPath);
      }
      // Swap the live DB connection to the app-documents copy.
      final currentDb = ref.read(databaseProvider);
      await currentDb.close();
      ref.read(databaseProvider.notifier).state = AppDatabase(appDbPath);
    }

    // 2. Clear the path in local storage (SharedPreferences)
    await bootstrapService.clearSyncFolderPath();

    // 3. Set root_folder_path to '' in the devices table for this device
    if (config != null) {
      final repo = ref.read(deviceRepositoryProvider);
      final device = await repo.getDeviceById(config.deviceId);
      if (device != null) {
        await repo.upsertDevice(
          domain.Device(
            deviceId: device.deviceId,
            deviceName: device.deviceName,
            rootFolderPath: '',
          ),
        );
      }
    }

    await _logDebugState('UNLINK:after');

    ref.invalidate(bootstrapConfigProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device unlinked successfully')),
      );
    }
  }

  void _onVersionTap() {
    final now = DateTime.now();
    if (_lastVersionTap != null &&
        now.difference(_lastVersionTap!) > const Duration(seconds: 3)) {
      _versionTapCount = 0;
    }
    _lastVersionTap = now;
    _versionTapCount++;
    if (_versionTapCount >= 5) {
      _versionTapCount = 0;
      context.push('/db-inspector');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(settingsNotifierProvider);
    final bootstrapConfig = ref.watch(bootstrapConfigProvider).valueOrNull;

    return settingsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (settings) {
        if (!_initialized) {
          _geminiCtrl.text = settings.geminiToken ?? '';
          _genModelCtrl.text = settings.genModel ?? '';
          _embedModelCtrl.text = settings.embedModel ?? '';
          _publishPerWeekCtrl.text = settings.publishPerWeek.toString();
          _trendFetchCountCtrl.text = settings.trendFetchCount.toString();
          _trendTagsPerPostCtrl.text = settings.trendTagsPerPost.toString();
          _postTagMinCtrl.text = settings.postTagMin.toString();
          _postTagMaxCtrl.text = settings.postTagMax.toString();
          _postTagExactCtrl.text = settings.postTagExact.toString();
          _linkedInClientIdCtrl.text = settings.linkedinClientId ?? '';
          _linkedInClientSecretCtrl.text = settings.linkedinClientSecret ?? '';
          _xClientIdCtrl.text = settings.xClientId ?? '';
          _xClientSecretCtrl.text = settings.xClientSecret ?? '';
          _initialized = true;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ── Appearance ───────────────────────────────────────────
              _SectionHeader('Appearance'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.brightness_6_outlined),
                          const SizedBox(width: 12),
                          const Text('Theme'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<String>(
                        expandedInsets: EdgeInsets.zero,
                        segments: const [
                          ButtonSegment(
                            value: 'system',
                            icon: Icon(Icons.brightness_auto, size: 18),
                            label: Text('Auto'),
                          ),
                          ButtonSegment(
                            value: 'light',
                            icon: Icon(Icons.light_mode, size: 18),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: 'dark',
                            icon: Icon(Icons.dark_mode, size: 18),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (val) {
                          ref
                              .read(settingsNotifierProvider.notifier)
                              .updateWith(
                                (s) => s.copyWith(themeMode: val.first),
                              );
                        },
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // ── LinkedIn ──────────────────────────────────────────────
              _SectionHeader('LinkedIn'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Credentials (5-tap unlock)
                      if (!_linkedInUnlocked)
                        GestureDetector(
                          onTap: () => _registerTap(
                            count: _linkedInTapCount,
                            lastTap: _lastLinkedInTap,
                            onUpdate: (c, t) => setState(() {
                              _linkedInTapCount = c;
                              _lastLinkedInTap = t;
                            }),
                            onUnlock: () =>
                                setState(() => _linkedInUnlocked = true),
                          ),
                          child: AbsorbPointer(
                            child: Column(
                              children: [
                                _LockedField(
                                  label: 'Client ID',
                                  value: settings.linkedinClientId ?? '',
                                ),
                                const SizedBox(height: 12),
                                _LockedField(
                                  label: 'Client Secret',
                                  obscure: true,
                                  value: settings.linkedinClientSecret ?? '',
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        TextField(
                          controller: _linkedInClientIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Client ID',
                            prefixIcon: Icon(Icons.apps),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _linkedInClientSecretCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Client Secret',
                            prefixIcon: Icon(Icons.key),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _linkedInUnlocked = false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () =>
                                  _saveLinkedInCredentials(settings),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      // Connect / disconnect row
                      Row(
                        children: [
                          Icon(
                            settings.isLinkedInConnected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: settings.isLinkedInConnected
                                ? Colors.green
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            settings.isLinkedInConnected
                                ? 'Connected'
                                : 'Not connected',
                          ),
                          const Spacer(),
                          if (_isConnectingLinkedIn)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (settings.isLinkedInConnected)
                            OutlinedButton(
                              onPressed: () => _disconnectLinkedIn(settings),
                              child: const Text('Disconnect'),
                            )
                          else
                            FilledButton(
                              onPressed: settings.hasLinkedInCredentials
                                  ? () => _connectLinkedIn(settings)
                                  : null,
                              child: const Text('Connect'),
                            ),
                        ],
                      ),
                      if (!settings.hasLinkedInCredentials)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Tap 5× above to enter your Client ID and Secret first',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── X (Twitter) ───────────────────────────────────────────
              _SectionHeader('X (Twitter)'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_xUnlocked)
                        GestureDetector(
                          onTap: () => _registerTap(
                            count: _xTapCount,
                            lastTap: _lastXTap,
                            onUpdate: (c, t) => setState(() {
                              _xTapCount = c;
                              _lastXTap = t;
                            }),
                            onUnlock: () => setState(() => _xUnlocked = true),
                          ),
                          child: AbsorbPointer(
                            child: Column(
                              children: [
                                _LockedField(
                                  label: 'Client ID',
                                  value: settings.xClientId ?? '',
                                ),
                                const SizedBox(height: 12),
                                _LockedField(
                                  label: 'Client Secret',
                                  obscure: true,
                                  value: settings.xClientSecret ?? '',
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        TextField(
                          controller: _xClientIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Client ID',
                            prefixIcon: Icon(Icons.apps),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _xClientSecretCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Client Secret',
                            prefixIcon: Icon(Icons.key),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _xUnlocked = false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => _saveXCredentials(settings),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                      const Divider(height: 24),
                      Row(
                        children: [
                          Icon(
                            settings.isXConnected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: settings.isXConnected
                                ? Colors.green
                                : Colors.grey,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            settings.isXConnected
                                ? 'Connected'
                                : 'Not connected',
                          ),
                          const Spacer(),
                          if (_isConnectingX)
                            const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else if (settings.isXConnected)
                            OutlinedButton(
                              onPressed: () => _disconnectX(settings),
                              child: const Text('Disconnect'),
                            )
                          else
                            FilledButton(
                              onPressed: settings.hasXCredentials
                                  ? () => _connectX(settings)
                                  : null,
                              child: const Text('Connect'),
                            ),
                        ],
                      ),
                      if (!settings.hasXCredentials)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'Tap 5× above to enter your Client ID first',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── AI ────────────────────────────────────────────────────
              _SectionHeader('AI Configuration'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_aiUnlocked)
                        GestureDetector(
                          onTap: () => _registerTap(
                            count: _aiTapCount,
                            lastTap: _lastAiTap,
                            onUpdate: (c, t) => setState(() {
                              _aiTapCount = c;
                              _lastAiTap = t;
                            }),
                            onUnlock: () => setState(() => _aiUnlocked = true),
                          ),
                          child: AbsorbPointer(
                            child: Column(
                              children: [
                                _LockedField(
                                  label: 'Gemini API Key',
                                  obscure: true,
                                  value: settings.geminiToken ?? '',
                                ),
                                const SizedBox(height: 12),
                                _LockedField(
                                  label: 'Text Generation Model',
                                  value: settings.effectiveGenModel,
                                ),
                                const SizedBox(height: 12),
                                _LockedField(
                                  label: 'Embedding Model',
                                  value: settings.effectiveEmbedModel,
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        TextField(
                          controller: _geminiCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Gemini API Key',
                            prefixIcon: Icon(Icons.key),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _genModelCtrl,
                          decoration: InputDecoration(
                            labelText: 'Text Generation Model',
                            hintText: settings.effectiveGenModel,
                            prefixIcon: const Icon(Icons.smart_toy_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _embedModelCtrl,
                          decoration: InputDecoration(
                            labelText: 'Embedding Model',
                            hintText: settings.effectiveEmbedModel,
                            prefixIcon: const Icon(Icons.data_array),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _aiUnlocked = false),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton(
                              onPressed: () => _saveAi(settings),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Publishing ────────────────────────────────────────────
              _SectionHeader('Publishing'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _publishPerWeekCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Publish Target (per week)',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => _savePublishPerWeek(settings),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Post ─────────────────────────────────────────────────
              _SectionHeader('Post'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Post Tag Count', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Range', style: TextStyle(fontSize: 14)),
                              value: 'range',
                              groupValue: settings.postTagMode,
                              onChanged: (val) => ref
                                  .read(settingsNotifierProvider.notifier)
                                  .updateWith((s) => s.copyWith(postTagMode: val)),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Exact', style: TextStyle(fontSize: 14)),
                              value: 'exact',
                              groupValue: settings.postTagMode,
                              onChanged: (val) => ref
                                  .read(settingsNotifierProvider.notifier)
                                  .updateWith((s) => s.copyWith(postTagMode: val)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (settings.postTagMode == 'range') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _postTagMinCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Min Tags',
                                  prefixIcon: Icon(Icons.arrow_downward),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _postTagMaxCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Max Tags',
                                  prefixIcon: Icon(Icons.arrow_upward),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        TextField(
                          controller: _postTagExactCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Tag Count',
                            prefixIcon: Icon(Icons.tag),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => _savePostSettings(settings),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Trending ──────────────────────────────────────────────
              _SectionHeader('Trending'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _trendFetchCountCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Dev.to Trend Fetch Count',
                          helperText: 'Number of articles to fetch from dev.to for trending tags',
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _trendTagsPerPostCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Trend Tags Per Post',
                          helperText: 'Number of top trending tags to auto-select via RAG per post',
                          prefixIcon: Icon(Icons.tag),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => _saveTrendingSettings(settings),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Manual Copy-to-Platform ───────────────────────────────
              _SectionHeader('Manual Post (Copy to Platform)'),
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const Icon(Icons.business_center_outlined),
                      title: const Text('Copy to LinkedIn'),
                      subtitle: const Text(
                        'Shows a button to copy content and open LinkedIn.\n'
                        'Note: Publishing is your responsibility — the app will mark the post as published when you tap the button.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: settings.copyToLinkedin,
                      onChanged: (val) {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .updateWith((s) => s.copyWith(copyToLinkedin: val));
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    SwitchListTile(
                      secondary: const Icon(Icons.tag),
                      title: const Text('Copy to X (Twitter)'),
                      subtitle: const Text(
                        'Shows a button to copy content and open X.\n'
                        'Note: Publishing is your responsibility — the app will mark the post as published when you tap the button.',
                        style: TextStyle(fontSize: 12),
                      ),
                      value: settings.copyToX,
                      onChanged: (val) {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .updateWith((s) => s.copyWith(copyToX: val));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Storage ───────────────────────────────────────────────
              _SectionHeader('Storage'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder_outlined),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Sync Folder'),
                                Text(
                                  bootstrapConfig?.syncFolderPath ?? 'Not configured',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (bootstrapConfig?.syncFolderPath != null &&
                          bootstrapConfig!.syncFolderPath!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            _FolderStatusChip(label: 'root', path: bootstrapConfig.syncFolderPath!),
                            _FolderStatusChip(label: '.media', path: p.join(bootstrapConfig.syncFolderPath!, '.media')),
                            _FolderStatusChip(label: 'share', path: p.join(bootstrapConfig.syncFolderPath!, 'share')),
                            _FolderStatusChip(label: '.backups', path: p.join(bootstrapConfig.syncFolderPath!, '.backups')),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => context.push('/folder-browser', extra: {
                              'label': 'Storage Explorer',
                              'path': bootstrapConfig.syncFolderPath!,
                            }),
                            icon: const Icon(Icons.folder_open, size: 18),
                            label: const Text('Explore'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _registerTap(
                            count: _unlinkTapCount,
                            lastTap: _lastUnlinkTap,
                            onUpdate: (c, t) => setState(() {
                              _unlinkTapCount = c;
                              _lastUnlinkTap = t;
                            }),
                            onUnlock: _unlinkDevice,
                          ),
                          icon: Icon(Icons.link_off, size: 16, color: theme.colorScheme.error),
                          label: Text(
                            _unlinkTapCount > 0
                                ? 'Unlink (${5 - _unlinkTapCount} more)'
                                : 'Unlink',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.error),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _onVersionTap,
                child: Center(
                  child: Text(
                    'Castpa v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _LockedField extends StatelessWidget {
  final String label;
  final String value;
  final bool obscure;

  const _LockedField({
    required this.label,
    required this.value,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(
          Icons.lock_outline,
          size: 18,
          color: Colors.grey,
        ),
      ),
      child: Text(
        obscure && value.isNotEmpty
            ? '••••••••••••'
            : (value.isEmpty ? '—' : value),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _FolderStatusChip extends StatelessWidget {
  final String label;
  final String path;

  const _FolderStatusChip({required this.label, required this.path});

  @override
  Widget build(BuildContext context) {
    final exists = Directory(path).existsSync();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          exists ? Icons.check_circle : Icons.cancel,
          size: 14,
          color: exists ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
