import 'dart:io';
import 'package:flutter/material.dart';
import 'package:castpa/data/services/media_file_service.dart';
import 'package:castpa/presentation/widgets/preview/linkable_text.dart';

class XPreviewCard extends StatelessWidget {
  final String content;
  final List<String> tags;
  final List<String> mediaPaths;

  const XPreviewCard({
    super.key,
    required this.content,
    required this.tags,
    this.mediaPaths = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade800,
                  child: const Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Creator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 4),
                          Text('@creator', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          const Spacer(),
                          Icon(Icons.more_horiz, color: Colors.grey.shade600, size: 18),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Content
                      LinkableText(
                        text: content,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                        linkStyle: const TextStyle(color: Color(0xFF1D9BF0), fontSize: 14, height: 1.4),
                      ),
                      // Tags
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 4,
                          children: tags.map((t) => Text('#$t ', style: const TextStyle(color: Color(0xFF1D9BF0), fontSize: 13))).toList(),
                        ),
                      ],
                      // Media (after content on X)
                      if (mediaPaths.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _XMediaPreview(mediaPaths: mediaPaths),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _XAction(icon: Icons.chat_bubble_outline, count: ''),
                          _XAction(icon: Icons.repeat, count: ''),
                          _XAction(icon: Icons.favorite_border, count: ''),
                          _XAction(icon: Icons.bar_chart, count: ''),
                          _XAction(icon: Icons.bookmark_border, count: ''),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _XMediaPreview extends StatefulWidget {
  final List<String> mediaPaths;
  const _XMediaPreview({required this.mediaPaths});

  @override
  State<_XMediaPreview> createState() => _XMediaPreviewState();
}

class _XMediaPreviewState extends State<_XMediaPreview> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final paths = widget.mediaPaths;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: paths.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _mediaWidget(paths[i]),
            ),
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
                color: i == _page ? const Color(0xFF1D9BF0) : Colors.grey.shade700,
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
      color: Colors.grey.shade900,
      child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white70, size: 48)),
    );
  }
}

class _XAction extends StatelessWidget {
  final IconData icon;
  final String count;

  const _XAction({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          if (count.isNotEmpty) ...[
            const SizedBox(width: 4),
            Text(count, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
