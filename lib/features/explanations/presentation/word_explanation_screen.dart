import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/word_explanation_models.dart';
import '../providers/explanations_provider.dart';

class WordExplanationScreen extends ConsumerWidget {
  const WordExplanationScreen({required this.wordId, super.key});

  final int wordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final explanationAsync = ref.watch(wordExplanationProvider(wordId));

    final strings = AppStrings.fromCode(
      ref.watch(languageProvider).languageCode,
    );

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: explanationAsync.when(
          loading: () => LoadingView(message: strings.explanationLoading),

          error: (error, stackTrace) => ErrorView(
            title: strings.explanationLoadFailed,
            onRetry: () {
              ref.invalidate(wordExplanationProvider(wordId));
            },
          ),

          data: (explanation) {
            if (explanation == null) {
              return EmptyView(title: strings.noWordExplanation);
            }

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.fromLTRB(6, 12, 6, 8),
                      child: _UnifiedExplanationBody(
                        explanation: explanation,
                        strings: strings,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _UnifiedExplanationBody extends StatelessWidget {
  const _UnifiedExplanationBody({
    required this.explanation,
    required this.strings,
  });

  final WordExplanationModel explanation;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final sections =
        <_ExplanationContentSection>[
              _ExplanationContentSection(
                title: strings.whatIs,
                content: explanation.whatIs,
                icon: Icons.help_outline_rounded,
              ),
              _ExplanationContentSection(
                title: strings.meaning,
                content: explanation.meaning,
                icon: Icons.lightbulb_outline_rounded,
              ),
              _ExplanationContentSection(
                title: strings.usage,
                content: explanation.usage,
                icon: Icons.auto_stories_outlined,
              ),
            ]
            .where(
              (section) =>
                  section.content != null && section.content!.trim().isNotEmpty,
            )
            .toList();

    final hasExamples = explanation.examples.isNotEmpty;

    final hasHint =
        explanation.hint != null && explanation.hint!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.verySoftGreen,
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            color: AppColors.textDark,
            size: 32,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          explanation.englishWord,
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontSize: 38),
        ),

        if ((explanation.translations ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),

          Text(
            explanation.translations!,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: 20,
              color: AppColors.textMuted,
            ),
          ),
        ],

        if (sections.isNotEmpty || hasExamples || hasHint)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, color: AppColors.divider),
          ),

        for (var i = 0; i < sections.length; i++) ...[
          _ExplanationSectionView(section: sections[i]),

          if (i != sections.length - 1 || hasExamples || hasHint)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: AppColors.divider),
            ),
        ],

        if (hasExamples) ...[
          _ExamplesSection(examples: explanation.examples, strings: strings),

          if (hasHint)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(height: 1, color: AppColors.divider),
            ),
        ],

        if (hasHint)
          _ExplanationSectionView(
            section: _ExplanationContentSection(
              title: strings.hint,
              content: explanation.hint,
              icon: Icons.tips_and_updates_outlined,
            ),
          ),
      ],
    );
  }
}

class _ExplanationContentSection {
  const _ExplanationContentSection({
    required this.title,
    required this.content,
    required this.icon,
  });

  final String title;
  final String? content;
  final IconData icon;
}

class _ExplanationSectionView extends StatelessWidget {
  const _ExplanationSectionView({required this.section});

  final _ExplanationContentSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.verySoftGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(section.icon, color: AppColors.textDark, size: 20),
            ),

            const SizedBox(width: 12),

            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          section.content!.trim(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.56),
        ),
      ],
    );
  }
}

class _ExamplesSection extends StatelessWidget {
  const _ExamplesSection({required this.examples, required this.strings});

  final List<ExampleModel> examples;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.verySoftGreen,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.format_quote_rounded,
                color: AppColors.textDark,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Text(
              strings.examples,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
          ],
        ),

        const SizedBox(height: 16),

        for (var i = 0; i < examples.length; i++) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
            decoration: BoxDecoration(
              color: AppColors.cardSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  examples[i].text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  examples[i].translation,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 15,
                    height: 1.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
