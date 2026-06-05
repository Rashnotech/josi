import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';

class RideHomeScreen extends StatefulWidget {
  const RideHomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<RideHomeScreen> createState() => _RideHomeScreenState();
}

class _RideHomeScreenState extends State<RideHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('ride-home-screen'),
      backgroundColor: JosiColors.mapGreen,
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _MapBackdrop()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Row(
                children: <Widget>[
                  const _TopBrand(),
                  const Spacer(),
                  _CircleAction(icon: Icons.notifications_none_rounded, onPressed: () {}),
                  const SizedBox(width: 10),
                  _CircleAction(icon: Icons.person_outline_rounded, onPressed: () {}),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _RideSheet(
              selectedIndex: _currentIndex,
              onDestinationSelected: (int index) => setState(() => _currentIndex = index),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBrand extends StatelessWidget {
  const _TopBrand();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.two_wheeler_rounded, color: JosiColors.red, size: 22),
          const SizedBox(width: 8),
          Text(
            'Josi Ride',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: JosiColors.black),
          ),
        ],
      ),
    );
  }
}

class _RideSheet extends StatelessWidget {
  const _RideSheet({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 28,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 58,
              height: 5,
              decoration: BoxDecoration(
                color: JosiColors.line,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            _DestinationSearch(onLaterPressed: () {}),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _QuickAction(
                    icon: Icons.home_filled,
                    label: 'Home',
                    selected: selectedIndex == 0,
                    onTap: () => onDestinationSelected(0),
                  ),
                ),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.calendar_month_rounded,
                    label: 'Rides',
                    selected: selectedIndex == 1,
                    onTap: () => onDestinationSelected(1),
                  ),
                ),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.account_circle_rounded,
                    label: 'Account',
                    selected: selectedIndex == 2,
                    onTap: () => onDestinationSelected(2),
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

class _DestinationSearch extends StatelessWidget {
  const _DestinationSearch({required this.onLaterPressed});

  final VoidCallback onLaterPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: JosiColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, color: JosiColors.black, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Where to?',
              style: Theme.of(context).textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: onLaterPressed,
            style: TextButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: JosiColors.ink,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              textStyle: Theme.of(context).textTheme.labelMedium,
            ),
            icon: const Icon(Icons.event_available_rounded, size: 18),
            label: const Text('Later'),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected ? JosiColors.red : JosiColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
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
      child: SizedBox.square(
        dimension: 46,
        child: IconButton(
          onPressed: onPressed,
          color: JosiColors.black,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AbujaMapPainter());
  }
}

class _AbujaMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(JosiColors.mapGreen, BlendMode.src);
    final Paint land = Paint()..color = const Color(0xFFEAF5E8);
    final Path district = Path()
      ..moveTo(0, size.height * 0.18)
      ..lineTo(size.width * 0.34, size.height * 0.08)
      ..lineTo(size.width * 0.92, size.height * 0.16)
      ..lineTo(size.width, size.height * 0.42)
      ..lineTo(size.width * 0.7, size.height * 0.56)
      ..lineTo(size.width * 0.16, size.height * 0.52)
      ..close();
    canvas.drawPath(district, land);

    final Paint road = Paint()
      ..color = JosiColors.mapRoad
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Paint roadLine = Paint()
      ..color = JosiColors.mapLine
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    _drawRoad(canvas, size, road, <Offset>[
      Offset(size.width * 0.05, size.height * 0.28),
      Offset(size.width * 0.28, size.height * 0.34),
      Offset(size.width * 0.52, size.height * 0.29),
      Offset(size.width * 0.95, size.height * 0.36),
    ]);
    _drawRoad(canvas, size, road, <Offset>[
      Offset(size.width * 0.18, size.height * 0.08),
      Offset(size.width * 0.26, size.height * 0.28),
      Offset(size.width * 0.2, size.height * 0.54),
      Offset(size.width * 0.38, size.height * 0.82),
    ]);
    _drawRoad(canvas, size, road, <Offset>[
      Offset(size.width * 0.7, size.height * 0.04),
      Offset(size.width * 0.64, size.height * 0.26),
      Offset(size.width * 0.72, size.height * 0.48),
      Offset(size.width * 0.66, size.height * 0.78),
    ]);

    for (int index = 0; index < 11; index++) {
      final double y = size.height * (0.13 + index * 0.063);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 36), roadLine);
    }

    _drawPin(canvas, Offset(size.width * 0.47, size.height * 0.36));
    _drawLabel(canvas, 'Abuja', Offset(size.width * 0.2, size.height * 0.26), 31);
    _drawLabel(canvas, 'Wuse', Offset(size.width * 0.48, size.height * 0.24), 16);
    _drawLabel(canvas, 'Maitama', Offset(size.width * 0.62, size.height * 0.18), 15);
    _drawLabel(canvas, 'Jabi', Offset(size.width * 0.33, size.height * 0.44), 15);
    _drawLabel(canvas, 'Asokoro', Offset(size.width * 0.64, size.height * 0.43), 15);
  }

  void _drawRoad(Canvas canvas, Size size, Paint paint, List<Offset> points) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int index = 1; index < points.length; index++) {
      final Offset previous = points[index - 1];
      final Offset current = points[index];
      path.quadraticBezierTo(
        (previous.dx + current.dx) / 2,
        previous.dy,
        current.dx,
        current.dy,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawPin(Canvas canvas, Offset center) {
    final Paint outer = Paint()..color = JosiColors.red.withOpacity(0.24);
    final Paint inner = Paint()..color = JosiColors.red;
    canvas.drawCircle(center, 22, outer);
    canvas.drawCircle(center, 8, inner);
  }

  void _drawLabel(Canvas canvas, String label, Offset offset, double size) {
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: JosiColors.black.withOpacity(0.48),
          fontFamily: 'Inter',
          fontSize: size,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
