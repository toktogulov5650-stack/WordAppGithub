import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../explanations/providers/explanations_provider.dart';

class UnknownWordsScreen extends ConsumerWidget {
  const UnknownWordsScreen({required this.testSessionId, super.key});

  final int testSessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(unknownWordsProvider(testSessionId));
    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return Scaffold(
      appBar: AppBar(title: Text(strings.unknownWords)),
      body: SafeArea(
        child: wordsAsync.when(
          loading: () => LoadingView(message: strings.unknownWordsLoading),
          error: (error, _) => ErrorView(
            title: strings.unknownWordsLoadFailed,
            onRetry: () => ref.invalidate(unknownWordsProvider(testSessionId)),
          ),
          data: (words) {
            if (words.isEmpty) {
              return EmptyView(
                title: strings.great,
                message: strings.noUnknownWords,
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(
                Responsive.horizontalPadding(
                  context,
                  compact: 18,
                  regular: 20,
                ),
                10,
                Responsive.horizontalPadding(
                  context,
                  compact: 18,
                  regular: 20,
                ),
                28,
              ),
              itemBuilder: (context, index) {
                final word = words[index];
                return AppCard(
                  radius: 22,
                  onTap: () => context.push('/word-explanation/${word.wordId}'),
                  padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
                  child: Row(
                    children: [
                      Container(
                        width: Responsive.value(context, 54, maxScale: 1),
                        height: Responsive.value(context, 54, maxScale: 1),
                        decoration: BoxDecoration(
                          color: AppColors.verySoftGreen,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.psychology_alt_rounded,
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              word.primaryTranslation,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
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
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemCount: words.length,
            );
          },
        ),
      ),
    );
  }
}
