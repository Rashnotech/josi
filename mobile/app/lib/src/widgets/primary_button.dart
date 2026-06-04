import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        child: Text(label, overflow: TextOverflow.ellipsis),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, overflow: TextOverflow.ellipsis),
    );
  }
}
