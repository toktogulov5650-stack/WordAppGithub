import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
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
      appBar: AppBar(title: Text(strings.words)),
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
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                  itemBuilder: (context, index) {
                    final word = words[index];
                    return AppCard(
                      radius: 22,
                      onTap: () =>
                          context.push('/word-explanation/${word.wordId}'),
                      padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: AppColors.verySoftGreen,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(
                              Icons.translate_rounded,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.englishWord,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontSize: 19),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  (word.primaryTranslation ?? '').isNotEmpty
                                      ? word.primaryTranslation!
                                      : strings.openExplanation,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.cardSecondary,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textTertiary,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemCount: words.length,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
