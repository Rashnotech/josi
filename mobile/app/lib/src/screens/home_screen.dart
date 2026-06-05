import 'package:flutter/material.dart';

import '../theme/josi_colors.dart';
import 'account_screen.dart';
import 'driver_on_way_screen.dart';

enum _BookingStep { riders, payment }

class RideHomeScreen extends StatefulWidget {
  const RideHomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<RideHomeScreen> createState() => _RideHomeScreenState();
}

class _RideHomeScreenState extends State<RideHomeScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  int _currentIndex = 0;
  _BookingStep _bookingStep = _BookingStep.riders;
  _RiderOption _selectedRider = _riderOptions.first;

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _handleDestinationSelected(int index) {
    if (index == 2) {
      Navigator.of(context).push(AccountScreen.smoothRoute());
      return;
    }
    setState(() => _currentIndex = index);
  }

  void _selectRider(_RiderOption rider) {
    setState(() {
      _selectedRider = rider;
      _bookingStep = _BookingStep.payment;
    });
  }

  void _resetBooking() {
    setState(() => _bookingStep = _BookingStep.riders);
  }

  void _selectPayment(String paymentMethod) {
    Navigator.of(context).push(
      DriverOnWayScreen.smoothRoute(
        driverName: _selectedRider.name,
        vehicle: _selectedRider.vehicle,
        rating: _selectedRider.rating,
        fare: _selectedRider.fare,
        pickup: _pickupController.text.trim().isEmpty ? 'Abuja-Keffi Expressway' : _pickupController.text.trim(),
        destination: _destinationController.text.trim().isEmpty ? 'J.T. Useni Way' : _destinationController.text.trim(),
        paymentMethod: paymentMethod,
      ),
    );
  }

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
          _BookingDrawer(
            pickupController: _pickupController,
            destinationController: _destinationController,
            selectedIndex: _currentIndex,
            bookingStep: _bookingStep,
            selectedRider: _selectedRider,
            onDestinationSelected: _handleDestinationSelected,
            onRiderSelected: _selectRider,
            onBackToRiders: _resetBooking,
            onPaymentSelected: _selectPayment,
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

class _BookingDrawer extends StatelessWidget {
  const _BookingDrawer({
    required this.pickupController,
    required this.destinationController,
    required this.selectedIndex,
    required this.bookingStep,
    required this.selectedRider,
    required this.onDestinationSelected,
    required this.onRiderSelected,
    required this.onBackToRiders,
    required this.onPaymentSelected,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final int selectedIndex;
  final _BookingStep bookingStep;
  final _RiderOption selectedRider;
  final ValueChanged<int> onDestinationSelected;
  final ValueChanged<_RiderOption> onRiderSelected;
  final VoidCallback onBackToRiders;
  final ValueChanged<String> onPaymentSelected;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.25,
      maxChildSize: 0.88,
      snap: true,
      snapSizes: const <double>[0.32, 0.62, 0.88],
      builder: (BuildContext context, ScrollController scrollController) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            key: const ValueKey<String>('booking-drawer'),
            constraints: const BoxConstraints(maxWidth: 560),
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
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 58,
                      height: 5,
                      decoration: BoxDecoration(
                        color: JosiColors.line,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _LocationCard(
                    pickupController: pickupController,
                    destinationController: destinationController,
                  ),
                  const SizedBox(height: 18),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: bookingStep == _BookingStep.riders
                        ? _NearbyRiderList(
                            key: const ValueKey<String>('nearby-rider-list'),
                            onRiderSelected: onRiderSelected,
                          )
                        : _PaymentSection(
                            key: const ValueKey<String>('payment-section'),
                            rider: selectedRider,
                            onBack: onBackToRiders,
                            onPaymentSelected: onPaymentSelected,
                          ),
                  ),
                  const SizedBox(height: 18),
                  _BottomNav(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({
    required this.pickupController,
    required this.destinationController,
  });

  final TextEditingController pickupController;
  final TextEditingController destinationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JosiColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: <Widget>[
          _LocationInputRow(
            key: const ValueKey<String>('pickup-location-row'),
            controller: pickupController,
            icon: Icons.radio_button_checked_rounded,
            iconColor: JosiColors.red,
            hintText: 'Enter pickup location',
            textInputAction: TextInputAction.next,
          ),
          const Divider(height: 1, indent: 58, color: JosiColors.line),
          _LocationInputRow(
            key: const ValueKey<String>('dropoff-location-row'),
            controller: destinationController,
            icon: Icons.location_on_rounded,
            iconColor: JosiColors.red,
            hintText: 'Where to?',
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}

class _LocationInputRow extends StatelessWidget {
  const _LocationInputRow({
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.hintText,
    required this.textInputAction,
    super.key,
  });

  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final String hintText;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 62,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 18),
          Icon(icon, color: iconColor, size: 25),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              key: ValueKey<String>(
                hintText == 'Enter pickup location' ? 'pickup-location-field' : 'dropoff-location-field',
              ),
              controller: controller,
              textInputAction: textInputAction,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JosiColors.ink),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JosiColors.muted),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: JosiColors.muted, size: 28),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _NearbyRiderList extends StatelessWidget {
  const _NearbyRiderList({
    required this.onRiderSelected,
    super.key,
  });

  final ValueChanged<_RiderOption> onRiderSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Nearby riders', style: Theme.of(context).textTheme.titleLarge),
            const Spacer(),
            Text(
              'Live proximity',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.red),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final _RiderOption rider in _riderOptions)
          _RiderOptionTile(
            rider: rider,
            onTap: () => onRiderSelected(rider),
          ),
      ],
    );
  }
}

class _RiderOptionTile extends StatelessWidget {
  const _RiderOptionTile({
    required this.rider,
    required this.onTap,
  });

  final _RiderOption rider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>('rider-${rider.name}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: JosiColors.line),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: JosiColors.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(rider.icon, color: JosiColors.black, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    rider.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    rider.vehicle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: JosiColors.muted),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.near_me_rounded, color: JosiColors.red, size: 17),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          rider.proximity,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.muted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(rider.fare, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  rider.arrival,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: JosiColors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentSection extends StatelessWidget {
  const _PaymentSection({
    required this.rider,
    required this.onBack,
    required this.onPaymentSelected,
    super.key,
  });

  final _RiderOption rider;
  final VoidCallback onBack;
  final ValueChanged<String> onPaymentSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'How would you like to pay?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            IconButton(
              onPressed: onBack,
              style: IconButton.styleFrom(
                backgroundColor: JosiColors.surface,
                foregroundColor: JosiColors.black,
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Set your payment method before requesting ${rider.name}.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: JosiColors.muted),
        ),
        const SizedBox(height: 18),
        _PaymentTabs(),
        const SizedBox(height: 12),
        _PaymentChoice(
          key: const ValueKey<String>('cash-payment-option'),
          icon: Icons.payments_rounded,
          iconColor: const Color(0xFF20B875),
          label: 'Cash',
          subtitle: 'Pay after your trip',
          onTap: () => onPaymentSelected('Cash'),
        ),
        const Divider(height: 1, color: JosiColors.line),
        _PaymentChoice(
          key: const ValueKey<String>('card-payment-option'),
          icon: Icons.add_rounded,
          iconColor: JosiColors.black,
          label: 'Add debit/credit card',
          subtitle: 'Use a card for this ride',
          onTap: () => onPaymentSelected('Card'),
        ),
      ],
    );
  }
}

class _PaymentTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Center(
            child: Text(
              'Personal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: JosiColors.muted),
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Text('Work', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Container(height: 3, color: JosiColors.red),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentChoice extends StatelessWidget {
  const _PaymentChoice({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: <Widget>[
            Icon(icon, color: iconColor, size: 34),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: JosiColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: JosiColors.muted, size: 28),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
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

    _drawRoad(canvas, road, <Offset>[
      Offset(size.width * 0.05, size.height * 0.28),
      Offset(size.width * 0.28, size.height * 0.34),
      Offset(size.width * 0.52, size.height * 0.29),
      Offset(size.width * 0.95, size.height * 0.36),
    ]);
    _drawRoad(canvas, road, <Offset>[
      Offset(size.width * 0.18, size.height * 0.08),
      Offset(size.width * 0.26, size.height * 0.28),
      Offset(size.width * 0.2, size.height * 0.54),
      Offset(size.width * 0.38, size.height * 0.82),
    ]);
    _drawRoad(canvas, road, <Offset>[
      Offset(size.width * 0.7, size.height * 0.04),
      Offset(size.width * 0.64, size.height * 0.26),
      Offset(size.width * 0.72, size.height * 0.48),
      Offset(size.width * 0.66, size.height * 0.78),
    ]);

    for (int index = 0; index < 11; index++) {
      final double y = size.height * (0.13 + index * 0.063);
      canvas.drawLine(Offset(-20, y), Offset(size.width + 20, y + 36), roadLine);
    }

    _drawRoute(canvas, size);
    _drawPin(canvas, Offset(size.width * 0.47, size.height * 0.36));
    _drawLabel(canvas, 'Abuja', Offset(size.width * 0.2, size.height * 0.26), 31);
    _drawLabel(canvas, 'Wuse', Offset(size.width * 0.48, size.height * 0.24), 16);
    _drawLabel(canvas, 'Maitama', Offset(size.width * 0.62, size.height * 0.18), 15);
    _drawLabel(canvas, 'Jabi', Offset(size.width * 0.33, size.height * 0.44), 15);
    _drawLabel(canvas, 'Asokoro', Offset(size.width * 0.64, size.height * 0.43), 15);
  }

  void _drawRoad(Canvas canvas, Paint paint, List<Offset> points) {
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

  void _drawRoute(Canvas canvas, Size size) {
    final Paint routePaint = Paint()
      ..color = JosiColors.red
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Path path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.44)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.39,
        size.width * 0.48,
        size.height * 0.46,
        size.width * 0.62,
        size.height * 0.42,
      )
      ..quadraticBezierTo(size.width * 0.74, size.height * 0.38, size.width * 0.84, size.height * 0.28);
    canvas.drawPath(path, routePaint);
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

class _RiderOption {
  const _RiderOption({
    required this.name,
    required this.vehicle,
    required this.arrival,
    required this.proximity,
    required this.fare,
    required this.rating,
    required this.icon,
  });

  final String name;
  final String vehicle;
  final String arrival;
  final String proximity;
  final String fare;
  final String rating;
  final IconData icon;
}

const List<_RiderOption> _riderOptions = <_RiderOption>[
  _RiderOption(
    name: 'Tanzir Fahad',
    vehicle: 'Toyota Allion, white',
    arrival: '3 min away',
    proximity: '0.7 km from pickup',
    fare: 'NGN 150',
    rating: '4.8',
    icon: Icons.directions_car_filled_rounded,
  ),
  _RiderOption(
    name: 'Amina Yusuf',
    vehicle: 'Keke CNG, green',
    arrival: '4 min away',
    proximity: '1.1 km from pickup',
    fare: 'NGN 100',
    rating: '4.7',
    icon: Icons.electric_rickshaw_rounded,
  ),
  _RiderOption(
    name: 'Chinedu Okafor',
    vehicle: 'Premium SUV, black',
    arrival: '6 min away',
    proximity: '1.8 km from pickup',
    fare: 'NGN 250',
    rating: '4.9',
    icon: Icons.airport_shuttle_rounded,
  ),
];
