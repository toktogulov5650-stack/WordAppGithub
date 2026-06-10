import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
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
                  padding: EdgeInsets.fromLTRB(
                    Responsive.horizontalPadding(context),
                    8,
                    Responsive.horizontalPadding(context),
                    40,
                  ),
                  children: [
                    _UnifiedExplanationBody(
                      explanation: explanation,
                      strings: strings,
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
                accentColor: AppColors.actionBlue,
              ),
              _ExplanationContentSection(
                title: strings.meaning,
                content: explanation.meaning,
                icon: Icons.lightbulb_outline_rounded,
                accentColor: AppColors.warning,
              ),
              _ExplanationContentSection(
                title: strings.usage,
                content: explanation.usage,
                icon: Icons.auto_stories_outlined,
                accentColor: AppColors.success,
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
        _WordHero(explanation: explanation, strings: strings),

        if (sections.isNotEmpty || hasExamples || hasHint) ...[
          const SizedBox(height: 28),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 24),
        ],

        for (var i = 0; i < sections.length; i++) ...[
          _ExplanationSectionView(section: sections[i]),

          if (i != sections.length - 1 || hasExamples || hasHint)
            const _SectionBreak(),
        ],

        if (hasExamples) ...[
          _ExamplesSection(examples: explanation.examples, strings: strings),

          if (hasHint) const _SectionBreak(),
        ],

        if (hasHint)
          _ExplanationSectionView(
            section: _ExplanationContentSection(
              title: strings.hint,
              content: explanation.hint,
              icon: Icons.tips_and_updates_outlined,
              accentColor: AppColors.secondaryPurple,
            ),
          ),
      ],
    );
  }
}

class _WordHero extends StatelessWidget {
  const _WordHero({required this.explanation, required this.strings});

  final WordExplanationModel explanation;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final translation = explanation.translations?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            explanation.englishWord,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontSize: Responsive.font(context, 40, minScale: 0.84),
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),

          if (translation != null && translation.isNotEmpty) ...[
            const SizedBox(height: 12),

            Text(
              translation,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: Responsive.font(context, 21),
                height: 1.34,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExplanationContentSection {
  const _ExplanationContentSection({
    required this.title,
    required this.content,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String? content;
  final IconData icon;
  final Color accentColor;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: section.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(section.icon, color: section.accentColor, size: 18),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Text(
                section.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: Responsive.font(context, 19),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Text(
          section.content!.trim(),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: Responsive.font(context, 17, minScale: 0.94),
            height: 1.62,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}

class _SectionBreak extends StatelessWidget {
  const _SectionBreak();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 22),
      child: Divider(height: 1, color: AppColors.divider),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.format_quote_rounded,
              color: AppColors.secondaryPurple,
              size: 21,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                strings.examples,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: Responsive.font(context, 19),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 17),

        for (var i = 0; i < examples.length; i++) ...[
          _ExampleItem(example: examples[i], number: i + 1),
          if (i != examples.length - 1) const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _ExampleItem extends StatelessWidget {
  const _ExampleItem({required this.example, required this.number});

  final ExampleModel example;
  final int number;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.actionBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              '$number',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.actionBlue,
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
                example.text,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: Responsive.font(context, 17, minScale: 0.94),
                  fontWeight: FontWeight.w600,
                  height: 1.48,
                  letterSpacing: 0,
                  color: AppColors.textDark,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                example.translation,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: Responsive.font(context, 15),
                  height: 1.48,
                  letterSpacing: 0,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
