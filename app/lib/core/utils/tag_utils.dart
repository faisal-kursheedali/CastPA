String toHashtag(String tag, {String format = 'camelCase'}) {
  return '#${toTag(tag, format: format)}';
}

String toTag(String tag, {String format = 'camelCase'}) {
  final cleaned = tag.trim().replaceAll('#', '');
  final words = cleaned.split(RegExp(r'[\s_]+'));
  if (words.isEmpty) return '';

  if (format == 'camelCase') {
    return words.first + words.skip(1).map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join();
  }
  return words.join('_');
}
