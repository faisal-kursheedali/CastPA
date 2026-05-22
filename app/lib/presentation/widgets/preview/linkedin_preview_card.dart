import 'dart:io';
import 'package:flutter/material.dart';
import 'package:castpa/data/services/media_file_service.dart';
import 'package:castpa/presentation/widgets/preview/linkable_text.dart';

class LinkedInPreviewCard extends StatelessWidget {
  final String content;
  final List<String> tags;
  final List<String> mediaPaths;

  const LinkedInPreviewCard({
    super.key,
    required this.content,
    required this.tags,
    this.mediaPaths = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF0A66C2),
                  child: const Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Creator', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 14)),
                      Text('Sharing ideas', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      Text('Just now • 🌐', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Colors.grey),
              ],
            ),
          ),
          // Media (before content on LinkedIn)
          if (mediaPaths.isNotEmpty) _MediaPreview(mediaPaths: mediaPaths),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: LinkableText(
              text: content,
              style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4),
              linkStyle: const TextStyle(color: Color(0xFF0A66C2), fontSize: 14, height: 1.4),
            ),
          ),
          // Tags
          if (tags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Wrap(
                spacing: 4,
                children: tags.map((t) => Text('#$t ', style: const TextStyle(color: Color(0xFF0A66C2), fontSize: 13))).toList(),
              ),
            ),
          const SizedBox(height: 12),
          // Reactions bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _ActionItem(icon: Icons.thumb_up_outlined, label: 'Like', color: Colors.grey.shade600),
                _ActionItem(icon: Icons.comment_outlined, label: 'Comment', color: Colors.grey.shade600),
                _ActionItem(icon: Icons.repeat, label: 'Repost', color: Colors.grey.shade600),
                _ActionItem(icon: Icons.send_outlined, label: 'Send', color: Colors.grey.shade600),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatefulWidget {
  final List<String> mediaPaths;
  const _MediaPreview({required this.mediaPaths});

  @override
  State<_MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<_MediaPreview> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final paths = widget.mediaPaths;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: paths.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _mediaWidget(paths[i]),
          ),
        ),
        if (paths.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(paths.length, (i) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _page ? const Color(0xFF0A66C2) : Colors.grey.shade300,
              ),
            )),
          ),
        ],
      ],
    );
  }

  Widget _mediaWidget(String path) {
    final isImg = MediaFileService.isImage(path);
    if (isImg) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (ctx, e, s) => _videoPlaceholder(),
      );
    }
    return _videoPlaceholder();
  }

  Widget _videoPlaceholder() {
    return Container(
      color: Colors.black,
      child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 48)),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
