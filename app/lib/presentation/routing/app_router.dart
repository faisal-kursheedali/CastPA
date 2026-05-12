import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:castpa/domain/entities/enums.dart';
import 'package:castpa/presentation/screens/home/home_screen.dart';
import 'package:castpa/presentation/screens/settings/settings_screen.dart';
import 'package:castpa/presentation/screens/settings/device_info_screen.dart';
import 'package:castpa/presentation/screens/settings/db_inspector_screen.dart';
import 'package:castpa/presentation/screens/category/category_manager_screen.dart';
import 'package:castpa/presentation/screens/post/create_post_screen.dart';
import 'package:castpa/presentation/screens/post/post_detail_screen.dart';
import 'package:castpa/presentation/screens/queue/queue_screen.dart';
import 'package:castpa/presentation/screens/onboarding/folder_setup_screen.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: (i) {
          setState(() => _selectedIndex = i);
          switch (i) {
            case 0:
              context.go('/');
            case 1:
              context.go('/settings');
          }
        },
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (ctx, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const HomeScreen()),
        GoRoute(
          path: '/settings',
          builder: (ctx, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/folder-setup',
      builder: (ctx, state) => const FolderSetupScreen(),
    ),
    GoRoute(
      path: '/categories',
      builder: (ctx, state) => const CategoryManagerScreen(),
    ),
    GoRoute(
      path: '/post/new',
      builder: (ctx, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (ctx, state) =>
          PostDetailScreen(postId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/queue/:status',
      builder: (ctx, state) {
        final statusKey = state.pathParameters['status']!;
        final status = PostStatus.fromKey(statusKey);
        final weekFilter = state.uri.queryParameters['week'] == 'true';
        final extraStatuses = status == PostStatus.published
            ? [PostStatus.partialPublished]
            : <PostStatus>[];
        return QueueScreen(status: status, extraStatuses: extraStatuses, filterCurrentWeek: weekFilter);
      },
    ),
    GoRoute(
      path: '/device-info',
      builder: (ctx, state) => const DeviceInfoScreen(),
    ),
    GoRoute(
      path: '/db-inspector',
      builder: (ctx, state) => const DbTablesScreen(),
    ),
    GoRoute(
      path: '/db-inspector/:table',
      builder: (ctx, state) =>
          DbTableScreen(tableName: state.pathParameters['table']!),
    ),
    GoRoute(
      path: '/db-inspector-local',
      builder: (ctx, state) => const LocalDeviceScreen(),
    ),
  ],
);
