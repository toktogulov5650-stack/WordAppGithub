import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/word_explanation_models.dart';
import '../providers/explanations_provider.dart';

class WordsByCategoryScreen extends ConsumerWidget {
  const WordsByCategoryScreen({required this.categoryId, super.key});

  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(wordsByCategoryProvider(categoryId));
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => LoadingView(message: strings.wordsLoading),
          error: (error, stackTrace) => ErrorView(
            title: strings.wordsLoadFailed,
            onRetry: () => ref.invalidate(wordsByCategoryProvider(categoryId)),
          ),
          data: (words) {
            if (words.isEmpty) {
              return EmptyView(title: strings.noCategoryExplanations);
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    Responsive.horizontalPadding(
                      context,
                      compact: 18,
                      regular: 22,
                    ),
                    8,
                    Responsive.horizontalPadding(
                      context,
                      compact: 18,
                      regular: 22,
                    ),
                    36,
                  ),
                  itemCount: words.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: _WordsHeader(title: strings.words),
                      );
                    }

                    final word = words[index - 1];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _DictionaryWordRow(
                        word: word,
                        strings: strings,
                        color: _accentForIndex(index),
                        onTap: () =>
                            context.push('/word-explanation/${word.wordId}'),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WordsHeader extends StatelessWidget {
  const _WordsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        fontSize: Responsive.font(context, 34),
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
  }
}

class _DictionaryWordRow extends StatelessWidget {
  const _DictionaryWordRow({
    required this.word,
    required this.strings,
    required this.color,
    required this.onTap,
  });

  final WordByCategoryModel word;
  final AppStrings strings;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trimmedWord = word.englishWord.trim();
    final initial = trimmedWord.isEmpty
        ? '?'
        : trimmedWord.substring(0, 1).toUpperCase();
    final translation = word.primaryTranslation;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF6F6F7)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.englishWord,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: Responsive.font(context, 21),
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      translation != null && translation.isNotEmpty
                          ? translation
                          : strings.openExplanation,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: Responsive.font(context, 15),
                        height: 1.42,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Color _accentForIndex(int index) {
  const colors = [
    AppColors.success,
    AppColors.secondaryPurple,
    AppColors.warning,
    AppColors.actionBlue,
  ];

  return colors[index % colors.length];
}
