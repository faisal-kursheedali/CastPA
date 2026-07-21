import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:castpa/presentation/widgets/common/media_item_widget.dart';
import 'package:castpa/presentation/widgets/preview/linkable_text.dart';

class XPreviewCard extends StatelessWidget {
  final String content;
  final List<String> tags;
  final List<String> mediaPaths;
  final String? firstComment;

  const XPreviewCard({
    super.key,
    required this.content,
    required this.tags,
    this.mediaPaths = const [],
    this.firstComment,
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
                      // First comment
                      if (firstComment != null && firstComment!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _XFirstCommentBlock(firstComment: firstComment!),
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

  Widget _mediaWidget(String path) => MediaItemWidget(path: path);
}

class _XFirstCommentBlock extends StatefulWidget {
  final String firstComment;

  const _XFirstCommentBlock({required this.firstComment});

  @override
  State<_XFirstCommentBlock> createState() => _XFirstCommentBlockState();
}

class _XFirstCommentBlockState extends State<_XFirstCommentBlock> {
  static const _accentColor = Color(0xFF1D9BF0);
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.firstComment));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _copyAndOpen() async {
    await Clipboard.setData(ClipboardData(text: widget.firstComment));
    final uri = Uri.parse('https://x.com/home');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('1st comment', style: TextStyle(fontSize: 10, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _copied
                    ? const Icon(Icons.check, key: ValueKey('check'), size: 15, color: Colors.green)
                    : IconButton(
                        key: const ValueKey('copy'),
                        icon: Icon(Icons.copy, size: 15, color: Colors.grey.shade500),
                        tooltip: 'Copy 1st comment',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _copy,
                      ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _copyAndOpen,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new, size: 13, color: _accentColor),
                      SizedBox(width: 3),
                      Text('Copy & open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _accentColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.firstComment, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
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
