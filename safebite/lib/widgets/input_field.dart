import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  // changed to onsaved for form usage, now allows null
  final void Function(String?)? onSaved;
  final String text;
  final String label;
  final String type;
  final String? error;
  const InputField(
      {required this.onSaved,
      required this.text,
      required this.label,
      required this.type,
      this.error,
      super.key});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  final TextEditingController _controller = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // function to toggle password visibility
  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // determine if the input should be obscured
    final isPassword = widget.type == "password";

    return Column(
      children: [
        if (widget.text.toLowerCase() != 'address')
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              capitalize(widget.text),
              style: TextStyle(
                  color: theme.colorScheme.onSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: widget.label == "number"
              ? TextInputType.number
              : TextInputType.text,
          // now correctly calls the onSaved prop
          onSaved: widget.onSaved,
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "please enter your ${widget.text}";
            }
            if (widget.type == "email") {
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(val)) {
                return "please enter a valid email format";
              }
            } else if (widget.type == "password") {
              final passwordRegex = RegExp(
                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>]).{6,}$',
              );
              if (!passwordRegex.hasMatch(val)) {
                return "include at least one a-z, a-z, 0-9, & special character";
              }
            } else if (widget.type == "address") {
              // basic address validation
              if (val.length < 10) {
                return "address is too short";
              }
              if (!RegExp(r'[A-Za-z]').hasMatch(val) ||
                  !RegExp(r'\d').hasMatch(val)) {
                return "address must contain both letters and numbers";
              }
            }
            return null;
          },

          obscureText: isPassword ? _obscureText : false,
          decoration: InputDecoration(
            hintText: "enter your ${widget.text}",
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onBackground.withOpacity(0.4),
            ),
            errorText: widget.error,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: _toggleObscureText,
                  )
                : null,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          cursorColor: theme.primaryColor,
        ),
      ],
    );
  }
}
