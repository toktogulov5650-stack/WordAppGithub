import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/language/app_strings.dart';
import 'core/language/language_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class WordApp extends ConsumerWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return MaterialApp.router(
      title: strings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
