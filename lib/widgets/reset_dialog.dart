import 'package:flutter/material.dart';

class ResetDialog extends StatelessWidget {
  final VoidCallback onReset;

  const ResetDialog({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Reset Calendar',
        style: TextStyle(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: const Text(
        'Are you sure you want to reset all colors? This action cannot be undone.',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text(
            'Reset',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onReset();
          },
        ),
      ],
    );
  }
}
