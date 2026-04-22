import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.hintText = 'Search items...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          // styling the container
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide.none,
          ),

          // hint text and icon
          hintText: hintText,
          hintStyle:
              TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5)),

          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),

          // clear button
          suffixIcon: (onClear != null &&
                  controller != null &&
                  controller!.text.isNotEmpty)
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  onPressed: onClear,
                )
              : null,
        ),
      ),
    );
  }
}
