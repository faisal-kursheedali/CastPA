import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';
import 'package:castpa/presentation/screens/post/post_edit_tab.dart';
import 'package:castpa/presentation/screens/post/post_preview_tab.dart';
import 'package:castpa/presentation/widgets/common/save_status_indicator.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await ref.read(postEditProvider.notifier).discardIfEmpty();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final saveState = ref.watch(postEditProvider).saveState;

    return PopScope(
      onPopInvokedWithResult: (_, __) => _onWillPop(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Post'),
          actions: [SaveStatusIndicator(saveState: saveState)],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Edit'),
              Tab(text: 'Preview'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            PostEditTab(),
            PostPreviewTab(),
          ],
        ),
      ),
    );
  }
}
