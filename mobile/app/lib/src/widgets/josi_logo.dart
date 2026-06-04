import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';

class JosiLogo extends StatelessWidget {
  const JosiLogo({
    super.key,
    this.width = 170,
    this.framed = false,
  });

  final double width;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final Widget logo = Semantics(
      label: 'Josi Ride logo',
      image: true,
      child: Image.asset(
        'assets/images/josi-logo.png',
        width: width,
        fit: BoxFit.contain,
      ),
    );

    if (!framed) {
      return logo;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.92)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: JosiColors.black.withOpacity(0.24),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: logo,
    );
  }
}
