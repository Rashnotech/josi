import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/router/app_router.dart';
import 'core/theme/josi_theme.dart';

void main() {
  runApp(const ProviderScope(child: JosiApp()));
}

class JosiApp extends ConsumerWidget {
  const JosiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Josi',
      debugShowCheckedModeBanner: false,
      theme: JosiTheme.light,
      routerConfig: router,
    );
  }
}
