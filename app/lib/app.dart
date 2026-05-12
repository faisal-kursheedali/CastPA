import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/core/theme/app_theme.dart';
import 'package:castpa/presentation/routing/app_router.dart';
import 'package:castpa/application/providers/bootstrap_provider.dart';
import 'package:castpa/application/providers/settings_notifier.dart';
import 'package:castpa/application/providers/service_providers.dart';
import 'package:castpa/presentation/screens/onboarding/folder_setup_screen.dart';

class CastpaApp extends ConsumerWidget {
  const CastpaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger trending fetch in background on app start; ignore result here.
    ref.watch(trendingInitProvider);
    final settings = ref.watch(settingsNotifierProvider).valueOrNull;
    final themeMode = switch (settings?.themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return MaterialApp.router(
      title: 'Castpa',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}

// Wrapper that handles bootstrap state before showing the main app
class AppBootstrap extends ConsumerWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configAsync = ref.watch(bootstrapConfigProvider);

    return configAsync.when(
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Bootstrap error: $e')),
        ),
      ),
      data: (config) {
        if (!config.hasSyncFolder) {
          return MaterialApp(
            title: 'Castpa',
            theme: AppTheme.light,
            home: const FolderSetupScreen(),
          );
        }
        return const CastpaApp();
      },
    );
  }
}
