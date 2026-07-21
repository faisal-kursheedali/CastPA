import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:castpa/presentation/widgets/common/media_item_widget.dart';
import 'package:castpa/presentation/widgets/preview/linkable_text.dart';

class LinkedInPreviewCard extends StatelessWidget {
  final String content;
  final List<String> tags;
  final List<String> mediaPaths;
  final String? firstComment;

  const LinkedInPreviewCard({
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
          // First comment
          if (firstComment != null && firstComment!.isNotEmpty)
            _FirstCommentBlock(
              firstComment: firstComment!,
              profileUrl: 'https://www.linkedin.com/in/me/recent-activity/all/',
              accentColor: const Color(0xFF0A66C2),
            ),
          const SizedBox(height: 8),
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

  Widget _mediaWidget(String path) => MediaItemWidget(path: path);
}

class _FirstCommentBlock extends StatefulWidget {
  final String firstComment;
  final String profileUrl;
  final Color accentColor;

  const _FirstCommentBlock({
    required this.firstComment,
    required this.profileUrl,
    required this.accentColor,
  });

  @override
  State<_FirstCommentBlock> createState() => _FirstCommentBlockState();
}

class _FirstCommentBlockState extends State<_FirstCommentBlock> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.firstComment));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _copyAndOpen() async {
    await Clipboard.setData(ClipboardData(text: widget.firstComment));
    final uri = Uri.parse(widget.profileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: widget.accentColor,
                child: const Text('C', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              const Text('1st comment', style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _copied
                    ? const Icon(Icons.check, key: ValueKey('check'), size: 15, color: Colors.green)
                    : IconButton(
                        key: const ValueKey('copy'),
                        icon: const Icon(Icons.copy, size: 15),
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.open_in_new, size: 13, color: widget.accentColor),
                      const SizedBox(width: 3),
                      Text('Copy & open', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: widget.accentColor)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(widget.firstComment, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
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
