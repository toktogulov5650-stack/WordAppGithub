import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';

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

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.textDark,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowStrong,
                          blurRadius: 22,
                          offset: Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    strings.chooseLanguage,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.chooseLanguageSubtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 28),
                  _LanguageOption(
                    title: strings.kyrgyz,
                    code: 'ky',
                    isSelected: _selectedLanguageCode == 'ky',
                    onTap: () => setState(() {
                      _selectedLanguageCode = 'ky';
                    }),
                  ),
                  const SizedBox(height: 12),
                  _LanguageOption(
                    title: strings.russian,
                    code: 'ru',
                    isSelected: _selectedLanguageCode == 'ru',
                    onTap: () => setState(() {
                      _selectedLanguageCode = 'ru';
                    }),
                  ),
                  const SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.background : AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? AppColors.textDark : AppColors.border,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  code.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? AppColors.textDark : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
