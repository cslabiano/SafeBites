import 'package:flutter/material.dart';

class InputField extends StatefulWidget {
  final Function callback;
  final String text;
  final String label;
  final String type;
  final String? error;
  const InputField(
      {required this.callback,
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
  // ignore: prefer_final_fields
  bool _obscureText = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String capitalize(String s) {
    if (s.isEmpty) {
      return s;
    }
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.text.toLowerCase() != 'address')
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              capitalize(widget.text),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
        const SizedBox(height: 4),
        TextFormField(
          keyboardType: widget.label == "number"
              ? TextInputType.number
              : TextInputType.text,
          onSaved: (val) {
            // ignore: avoid_print
            print("Text value: ${val!}");
          },
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "Please enter your ${widget.text}";
            }
            if (widget.type == "email") {
              final emailRegex =
                  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
              if (!emailRegex.hasMatch(val)) {
                return "Please enter a valid email format";
              }
            } else if (widget.type == "password") {
              final passwordRegex = RegExp(
                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()\-_=+{};:,<.>]).{6,}$',
              );
              if (!passwordRegex.hasMatch(val)) {
                return "Include at least one A-Z, a-z, 0-9, & special character";
              }
            } else if (widget.type == "address") {
              // Basic address validation
              if (val.length < 10) {
                return "Address is too short";
              }
              if (!RegExp(r'[A-Za-z]').hasMatch(val) ||
                  !RegExp(r'\d').hasMatch(val)) {
                return "Address must contain both letters and numbers";
              }
            }
            return null;
          },
          controller: _controller,
          onChanged: (value) {
            widget.callback(_controller.text);
          },
          obscureText: widget.type == "password" ? _obscureText : false,
          decoration: InputDecoration(
            hintText: "Enter your ${widget.text}",
            hintStyle: TextStyle(
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            errorText: widget.error,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.tertiary,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          cursorColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}
