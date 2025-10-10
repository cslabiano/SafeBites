import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  // final Function callback;
  final VoidCallback callback;
  final String text;
  final String type; // 'filled', 'outlined', 'text', 'elevated'
  const Button(
      {required this.callback,
      required this.text,
      required this.type,
      super.key});

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (widget.type) {
      case 'outlined':
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: widget.callback,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.primary),
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(widget.text),
          ),
        );

      case 'text':
        return SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: widget.callback,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(widget.text),
          ),
        );

      case 'elevated':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.callback,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(widget.text),
          ),
        );

      case 'filled':
      default:
        return SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: widget.callback,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(widget.text),
          ),
        );
    }
  }
}
