import 'package:flutter/material.dart';
import 'glass_container.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        onChanged: onChanged,
        onSubmitted: (_) => onSubmitted?.call(),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      ),
    );
  }
}
