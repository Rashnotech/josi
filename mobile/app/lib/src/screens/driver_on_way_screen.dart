import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';

class DriverOnWayScreen extends StatelessWidget {
  const DriverOnWayScreen({
    required this.driverName,
    required this.vehicle,
    required this.rating,
    required this.fare,
    required this.pickup,
    required this.destination,
    required this.paymentMethod,
    super.key,
  });

  static Route<void> smoothRoute({
    required String driverName,
    required String vehicle,
    required String rating,
    required String fare,
    required String pickup,
    required String destination,
    required String paymentMethod,
  }) {
    return PageRouteBuilder<void>(
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return DriverOnWayScreen(
          driverName: driverName,
          vehicle: vehicle,
          rating: rating,
          fare: fare,
          pickup: pickup,
          destination: destination,
          paymentMethod: paymentMethod,
        );
      },
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        final CurvedAnimation curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  final String driverName;
  final String vehicle;
  final String rating;
  final String fare;
  final String pickup;
  final String destination;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('driver-on-way-screen'),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _DriverMapLayer()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
              child: Row(
                children: <Widget>[
                  _RoundButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Driver on the way',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: JosiColors.black),
                      ),
                    ),
                  ),
                  _RoundButton(icon: Icons.headset_mic_outlined, onPressed: () {}),
                ],
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 336,
            child: _RoundButton(icon: Icons.near_me_rounded, onPressed: () {}),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _DriverStatusPanel(
              driverName: driverName,
              vehicle: vehicle,
              rating: rating,
              fare: fare,
              pickup: pickup,
              destination: destination,
              paymentMethod: paymentMethod,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      child: SizedBox.square(
        dimension: 48,
        child: IconButton(
          onPressed: onPressed,
          color: JosiColors.black,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _DriverStatusPanel extends StatelessWidget {
  const _DriverStatusPanel({
    required this.driverName,
    required this.vehicle,
    required this.rating,
    required this.fare,
    required this.pickup,
    required this.destination,
    required this.paymentMethod,
  });

  final String driverName;
  final String vehicle;
  final String rating;
  final String fare;
  final String pickup;
  final String destination;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Arriving in', style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        '3 mins',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: JosiColors.red),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: JosiColors.line),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Dhaka Metro',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.muted),
                      ),
                      const SizedBox(height: 3),
                      Text('11-2233', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                const _DriverAvatar(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(driverName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 3),
                      Text(
                        vehicle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: JosiColors.muted),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: <Widget>[
                          for (int index = 0; index < 4; index++)
                            const Icon(Icons.star_rate_rounded, color: Color(0xFFFFC107), size: 18),
                          const Icon(Icons.star_rate_rounded, color: JosiColors.line, size: 18),
                          const SizedBox(width: 5),
                          Text(rating, style: Theme.of(context).textTheme.labelMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                _ContactButton(icon: Icons.call_rounded, onPressed: () {}),
                const SizedBox(width: 10),
                _ContactButton(icon: Icons.chat_bubble_rounded, onPressed: () {}),
              ],
            ),
            const SizedBox(height: 18),
            const Divider(color: JosiColors.line),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(child: _TripFact(label: 'Pickup', value: pickup)),
                Expanded(child: _TripFact(label: 'Drop-off', value: destination)),
                Expanded(child: _TripFact(label: 'Fare', value: fare)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Payment: $paymentMethod',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.muted),
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      foregroundColor: JosiColors.red,
                      side: const BorderSide(color: JosiColors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text('Cancel Ride'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: JosiColors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    icon: const Icon(Icons.share_rounded, size: 20),
                    label: const Text('Share Trip'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: JosiColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.person_rounded, color: JosiColors.black, size: 36),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: JosiColors.red.withOpacity(0.08),
      shape: const CircleBorder(),
      child: SizedBox.square(
        dimension: 48,
        child: IconButton(
          onPressed: onPressed,
          color: JosiColors.red,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _TripFact extends StatelessWidget {
  const _TripFact({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.muted),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.black),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DriverMapLayer extends StatelessWidget {
  const _DriverMapLayer();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;

        return Stack(
          children: <Widget>[
            Positioned.fill(child: CustomPaint(painter: _DriverMapPainter())),
            Positioned(
              left: width * 0.48 - 42,
              top: height * 0.24 - 42,
              child: const _MapIconPulse(
                key: ValueKey<String>('driver-map-car-icon'),
                icon: Icons.directions_car_filled_rounded,
                size: 84,
                iconSize: 42,
                rotation: -0.52,
              ),
            ),
            Positioned(
              left: width * 0.62 - 28,
              top: height * 0.54 - 28,
              child: const _MapIconPulse(
                key: ValueKey<String>('driver-map-person-icon'),
                icon: Icons.person_rounded,
                size: 56,
                iconSize: 28,
                backgroundColor: JosiColors.red,
                iconColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MapIconPulse extends StatelessWidget {
  const _MapIconPulse({
    required this.icon,
    required this.size,
    required this.iconSize,
    this.rotation = 0,
    this.backgroundColor = Colors.white,
    this.iconColor = JosiColors.black,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double rotation;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: JosiColors.red.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
          ),
          Transform.rotate(
            angle: rotation,
            child: Container(
              width: size * 0.48,
              height: size * 0.48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(icon, color: iconColor, size: iconSize),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF2F4F3), BlendMode.src);
    final Paint park = Paint()..color = const Color(0xFFDFF1E5);
    final Paint road = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint thinRoad = Paint()
      ..color = const Color(0xFFE1E5E7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int index = 0; index < 7; index++) {
      final double x = size.width * (0.1 + index * 0.15);
      canvas.drawRect(Rect.fromLTWH(x, size.height * 0.16, 44, 70), park);
    }

    for (int index = 0; index < 9; index++) {
      final double y = size.height * (0.12 + index * 0.08);
      canvas.drawLine(Offset(-30, y), Offset(size.width + 30, y + 90), road);
      canvas.drawLine(Offset(-30, y), Offset(size.width + 30, y + 90), thinRoad);
    }

    final Paint route = Paint()
      ..color = JosiColors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Path path = Path()
      ..moveTo(size.width * 0.52, size.height * 0.26)
      ..lineTo(size.width * 0.68, size.height * 0.36)
      ..lineTo(size.width * 0.56, size.height * 0.44)
      ..lineTo(size.width * 0.62, size.height * 0.54);
    canvas.drawPath(path, route);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
