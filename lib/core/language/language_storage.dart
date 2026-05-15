import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final languageStorageProvider = Provider<LanguageStorage>((ref) {
  return const LanguageStorage(FlutterSecureStorage());
});

class LanguageStorage {
  const LanguageStorage(this._storage);

  static const _languageKey = 'preferred_language';

  final FlutterSecureStorage _storage;

  Future<void> saveLanguageCode(String languageCode) async {
    await _storage.write(key: _languageKey, value: languageCode);
  }

  Future<String?> readLanguageCode() async {
    return _storage.read(key: _languageKey);
  }
}
