import 'package:flutter/material.dart';
import 'package:castpa/application/notifiers/post_edit_notifier.dart';

class SaveStatusIndicator extends StatelessWidget {
  final SaveState saveState;

  const SaveStatusIndicator({super.key, required this.saveState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: switch (saveState) {
        SaveState.saving => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 6),
              Text('Saving…', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        SaveState.saved => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check, size: 14, color: Colors.green),
              SizedBox(width: 4),
              Text('Saved', style: TextStyle(fontSize: 12, color: Colors.green)),
            ],
          ),
        SaveState.error => const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 14, color: Colors.red),
              SizedBox(width: 4),
              Text('Error', style: TextStyle(fontSize: 12, color: Colors.red)),
            ],
          ),
        SaveState.idle => const SizedBox.shrink(),
        SaveState.deleted => const SizedBox.shrink(),
      },
    );
  }
}
