import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

/// Root widget for the Zeylo application
class ZeyloApp extends ConsumerWidget {
  const ZeyloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Zeylo',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
