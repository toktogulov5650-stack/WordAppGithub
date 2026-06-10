import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  String _selectedLanguageCode = defaultLanguageCode;
  bool _isSaving = false;

  Future<void> _continue() async {
    setState(() => _isSaving = true);
    await ref
        .read(languageProvider.notifier)
        .setLanguage(_selectedLanguageCode);
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.fromCode(_selectedLanguageCode);
    final horizontalPadding = Responsive.horizontalPadding(context);
    final logoSize = Responsive.value(context, 78, minScale: 0.88, maxScale: 1);

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              Responsive.verticalGap(context, 38),
              horizontalPadding,
              28,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: AppLogo(size: logoSize)),
                  SizedBox(height: Responsive.verticalGap(context, 32)),
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: const Color(0xFFEDEDF0)),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowSoft,
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _LanguageOption(
                          title: strings.kyrgyz,
                          code: 'ky',
                          isSelected: _selectedLanguageCode == 'ky',
                          onTap: () => setState(() {
                            _selectedLanguageCode = 'ky';
                          }),
                        ),
                        const SizedBox(height: 6),
                        _LanguageOption(
                          title: strings.russian,
                          code: 'ru',
                          isSelected: _selectedLanguageCode == 'ru',
                          onTap: () => setState(() {
                            _selectedLanguageCode = 'ru';
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Responsive.verticalGap(context, 22)),
                  AppButton(
                    label: strings.continueLabel,
                    icon: Icons.arrow_forward_rounded,
                    isLoading: _isSaving,
                    onPressed: _isSaving ? null : _continue,
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textDark : Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: isSelected ? AppColors.textDark : Colors.transparent,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.shadowSoft,
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.12)
                      : const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.16)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFFF7F7F8),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textTertiary.withValues(alpha: 0.45),
                  ),
                ),
                child: Icon(
                  isSelected ? Icons.check_rounded : Icons.circle_outlined,
                  color: isSelected
                      ? AppColors.textDark
                      : Colors.transparent,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
