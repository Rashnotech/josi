import 'package:flutter/material.dart';

import 'screens/account_screen.dart';
import 'screens/home_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/josi_theme.dart';

class JosiRideApp extends StatelessWidget {
  const JosiRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Josi Ride',
      debugShowCheckedModeBanner: false,
      theme: JosiTheme.light,
      routes: <String, WidgetBuilder>{
        SignInScreen.routeName: (BuildContext context) => const SignInScreen(),
        RideHomeScreen.routeName: (BuildContext context) => const RideHomeScreen(),
        AccountScreen.routeName: (BuildContext context) => const AccountScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
