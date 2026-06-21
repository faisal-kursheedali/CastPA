import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:castpa/data/services/media_file_service.dart';

class FolderBrowserScreen extends StatefulWidget {
  final String label;
  final String folderPath;

  const FolderBrowserScreen({
    super.key,
    required this.label,
    required this.folderPath,
  });

  @override
  State<FolderBrowserScreen> createState() => _FolderBrowserScreenState();
}

class _FolderBrowserScreenState extends State<FolderBrowserScreen> {
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.folderPath;
  }

  List<FileSystemEntity> _listEntries() {
    final dir = Directory(_currentPath);
    if (!dir.existsSync()) return [];
    final entries = dir.listSync()..sort((a, b) {
      final aIsDir = a is Directory;
      final bIsDir = b is Directory;
      if (aIsDir && !bIsDir) return -1;
      if (!aIsDir && bIsDir) return 1;
      return a.path.compareTo(b.path);
    });
    return entries;
  }

  String get _relativePath {
    if (_currentPath == widget.folderPath) return '/';
    return '/${p.relative(_currentPath, from: widget.folderPath)}';
  }

  bool get _isRoot => _currentPath == widget.folderPath;

  void _navigateTo(String path) => setState(() => _currentPath = path);

  void _goUp() {
    if (_isRoot) return;
    setState(() => _currentPath = p.dirname(_currentPath));
  }

  void _showImagePreview(String filePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(p.basename(filePath), style: const TextStyle(fontSize: 14)),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.6,
              ),
              child: Image.file(
                File(filePath),
                fit: BoxFit.contain,
                errorBuilder: (_, e, s) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _iconForFile(String name) {
    final ext = p.extension(name).toLowerCase();
    if (MediaFileService.isImage(name)) return Icons.image;
    if (MediaFileService.isVideo(name)) return Icons.videocam;
    if (ext == '.db') return Icons.storage;
    if (ext == '.json') return Icons.data_object;
    return Icons.insert_drive_file;
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final entries = _listEntries();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${entries.length} items',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                if (!_isRoot)
                  GestureDetector(
                    onTap: _goUp,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.arrow_upward, size: 18),
                    ),
                  ),
                Expanded(
                  child: Text(
                    _relativePath,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('Folder is empty'))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (_, i) {
                      final entity = entries[i];
                      final name = p.basename(entity.path);
                      final isDir = entity is Directory;
                      final isImage = !isDir && MediaFileService.isImage(name);

                      Widget? trailing;
                      String subtitle;
                      if (isDir) {
                        try {
                          final count = Directory(entity.path).listSync().length;
                          subtitle = '$count items';
                        } catch (_) {
                          subtitle = 'inaccessible';
                        }
                        trailing = const Icon(Icons.chevron_right, size: 20);
                      } else {
                        final stat = entity.statSync();
                        subtitle = _formatSize(stat.size);
                        if (isImage) {
                          trailing = ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(entity.path),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, s) => const Icon(Icons.broken_image, size: 20),
                            ),
                          );
                        }
                      }

                      return ListTile(
                        leading: Icon(
                          isDir ? Icons.folder : _iconForFile(name),
                          color: isDir ? theme.colorScheme.primary : null,
                        ),
                        title: Text(name, style: const TextStyle(fontSize: 14)),
                        subtitle: Text(subtitle),
                        trailing: trailing,
                        onTap: isDir
                            ? () => _navigateTo(entity.path)
                            : isImage
                                ? () => _showImagePreview(entity.path)
                                : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
