import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _checked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_checked) {
      return;
    }
    _checked = true;
    Future.microtask(() => ref.read(authProvider.notifier).checkSession());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.fromCode(ref.watch(languageProvider).languageCode);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDFDFE),
              AppColors.background,
              AppColors.backgroundElevated,
            ],
          ),
        ),
        child: Stack(
          children: [
            const _Glow(
              alignment: Alignment.topRight,
              color: AppColors.softBlue,
              size: 300,
              offset: Offset(90, -40),
            ),
            const _Glow(
              alignment: Alignment.bottomLeft,
              color: AppColors.cardSecondary,
              size: 260,
              offset: Offset(-70, 70),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: Container(
                        width: 420,
                        padding: const EdgeInsets.fromLTRB(28, 34, 28, 30),
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.circular(36),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.85),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadowSoft,
                              blurRadius: 28,
                              offset: Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 94,
                              height: 94,
                              decoration: BoxDecoration(
                                color: AppColors.textDark,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadowStrong,
                                    blurRadius: 24,
                                    offset: Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Colors.white,
                                size: 46,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Text(
                              strings.appName,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontSize: 32),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              strings.splashSubtitle,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 26),
                            const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({
    required this.alignment,
    required this.color,
    required this.size,
    required this.offset,
  });

  final Alignment alignment;
  final Color color;
  final double size;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: IgnorePointer(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withValues(alpha: 0.92),
                  color.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
