import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'language_storage.dart';

const supportedLanguageCodes = {'ky', 'ru'};
const defaultLanguageCode = 'ky';

class LanguageState {
  const LanguageState({required this.isLoading, this.languageCode});

  final bool isLoading;
  final String? languageCode;

  bool get hasLanguage => languageCode != null;
}

final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(
  LanguageNotifier.new,
);

class LanguageNotifier extends Notifier<LanguageState> {
  LanguageStorage get _storage => ref.read(languageStorageProvider);

  @override
  LanguageState build() {
    Future.microtask(_load);
    return const LanguageState(isLoading: true);
  }

  Future<void> _load() async {
    final savedLanguageCode = await _storage.readLanguageCode();
    state = LanguageState(
      isLoading: false,
      languageCode: normalizeLanguageCode(savedLanguageCode),
    );
  }

  Future<void> setLanguage(String languageCode) async {
    final normalized = normalizeLanguageCode(languageCode) ?? defaultLanguageCode;
    await _storage.saveLanguageCode(normalized);
    state = LanguageState(isLoading: false, languageCode: normalized);
  }
}

String? normalizeLanguageCode(String? languageCode) {
  final normalized = languageCode?.trim().toLowerCase();
  if (normalized == null || !supportedLanguageCodes.contains(normalized)) {
    return null;
  }
  return normalized;
}
