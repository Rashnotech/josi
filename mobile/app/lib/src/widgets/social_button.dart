import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';

class SocialButton extends StatelessWidget {
  const SocialButton({
    required this.label,
    required this.mark,
    required this.markColor,
    required this.onPressed,
    super.key,
  });

  final String label;
  final String mark;
  final Color markColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        foregroundColor: JosiColors.ink,
        side: const BorderSide(color: JosiColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: markColor.withOpacity(0.11),
              shape: BoxShape.circle,
            ),
            child: Text(
              mark,
              style: TextStyle(
                color: markColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
