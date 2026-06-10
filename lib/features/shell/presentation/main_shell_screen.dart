import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../explanations/presentation/explanations_home_screen.dart';
import '../../flashcards/presentation/flashcards_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../tests/presentation/tests_home_screen.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({this.initialIndex = 0, super.key});

  final int initialIndex;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  late int _currentIndex = widget.initialIndex.clamp(0, 3);

  final _pages = const [
    TestsHomeScreen(),
    FlashcardsScreen(),
    ExplanationsHomeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );
    final isCompact = Responsive.isCompact(context);

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isCompact ? 10 : 16,
            8,
            isCompact ? 10 : 16,
            14,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadowSoft,
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: NavigationBar(
                height: isCompact ? 60 : 64,
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() => _currentIndex = index);
                },
                destinations: [
                  NavigationDestination(
                    icon: const Icon(Icons.quiz_outlined),
                    selectedIcon: const Icon(Icons.quiz_rounded),
                    label: strings.tests,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.style_outlined),
                    selectedIcon: const Icon(Icons.style_rounded),
                    label: strings.flashcards,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.menu_book_outlined),
                    selectedIcon: const Icon(Icons.menu_book_rounded),
                    label: strings.explanations,
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.person_outline_rounded),
                    selectedIcon: const Icon(Icons.person_rounded),
                    label: strings.profile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
