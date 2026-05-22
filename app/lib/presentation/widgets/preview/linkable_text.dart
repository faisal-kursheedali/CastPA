import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? linkStyle;

  const LinkableText({
    super.key,
    required this.text,
    this.style,
    this.linkStyle,
  });

  static final _urlRegex = RegExp(
    r'(?:https?://|www\.)[^\s]*'
    r'|[a-zA-Z0-9][a-zA-Z0-9\-]*\.[a-zA-Z]{2,}[^\s]*',
    caseSensitive: false,
  );

  Future<void> _launch(String url) async {
    final normalized = (url.startsWith('http://') || url.startsWith('https://'))
        ? url
        : 'https://$url';
    final uri = Uri.tryParse(normalized);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    int last = 0;

    for (final match in _urlRegex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start), style: style));
      }
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: (linkStyle ?? style)?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ) ?? TextStyle(
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()..onTap = () => _launch(url),
      ));
      last = match.end;
    }

    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last), style: style));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
