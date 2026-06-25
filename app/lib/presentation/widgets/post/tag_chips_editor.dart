import 'package:flutter/material.dart';
import 'package:castpa/core/utils/tag_utils.dart';

class TagChipsEditor extends StatefulWidget {
  final List<String> tags;
  final String label;
  final bool readOnly;
  final void Function(List<String>)? onChanged;
  final String tagFormat;

  const TagChipsEditor({
    super.key,
    required this.tags,
    required this.label,
    this.readOnly = false,
    this.onChanged,
    this.tagFormat = 'camelCase',
  });

  @override
  State<TagChipsEditor> createState() => _TagChipsEditorState();
}

class _TagChipsEditorState extends State<TagChipsEditor> {
  late List<String> _tags;
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.tags);
  }

  @override
  void didUpdateWidget(TagChipsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tags != widget.tags) {
      _tags = List.from(widget.tags);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _addTag(String value) {
    final trimmed = toTag(value, format: widget.tagFormat);
    if (trimmed.isEmpty || _tags.contains(trimmed)) return;
    setState(() => _tags.add(trimmed));
    _ctrl.clear();
    widget.onChanged?.call(_tags);
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged?.call(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            ..._tags.map((tag) => Chip(
              label: Text('#$tag', style: const TextStyle(fontSize: 12)),
              onDeleted: widget.readOnly ? null : () => _removeTag(tag),
              deleteIconColor: Colors.grey,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),
            if (!widget.readOnly)
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: 'Add tag...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  style: const TextStyle(fontSize: 13),
                  onSubmitted: _addTag,
                  textInputAction: TextInputAction.done,
                ),
              ),
          ],
        ),
        const Divider(height: 16),
      ],
    );
  }
}
