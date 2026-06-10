import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/storage/token_storage.dart';
import '../../tests/providers/categories_provider.dart';
import '../../tests/providers/records_provider.dart';
import '../../tests/providers/test_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_models.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    bool clearUser = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final profileUserProvider = FutureProvider<UserModel>((ref) async {
  final authState = ref.read(authProvider);
  if (authState.user != null) {
    return authState.user!;
  }

  final user = await ref.read(authApiProvider).getCurrentUser();
  await ref.read(languageProvider.notifier).setLanguage(user.preferredLanguage);
  ref.read(authProvider.notifier).setUser(user);
  return user;
});

class AuthNotifier extends Notifier<AuthState> {
  static const _defaultGoogleClientId =
      '204077634716-56jbenjk4g3r7cb726qmlchnrg2ms1gf.apps.googleusercontent.com';
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: _defaultGoogleClientId,
  );
  static const _googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: _googleWebClientId,
  );

  AuthApi get _authApi => ref.read(authApiProvider);
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);
  SessionController get _sessionController =>
      ref.read(sessionControllerProvider);
  LanguageNotifier get _languageNotifier => ref.read(languageProvider.notifier);
  AppStrings get _strings =>
      AppStrings.fromCode(ref.read(languageProvider).languageCode);
  String get _preferredLanguage =>
      ref.read(languageProvider).languageCode ?? defaultLanguageCode;
  String get _authTokenMissingMessage => _strings.isRu
      ? 'Сервер не вернул токен авторизации.'
      : 'Сервер авторизация токенин кайтарган жок.';

  @override
  AuthState build() {
    ref.listen<SessionController>(sessionControllerProvider, (previous, next) {
      if (next.isUnauthorized) {
        _clearUserDataCache();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
    return AuthState.initial();
  }

  Future<void> checkSession() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    await _tokenStorage.clearToken();
    await _signOutGoogle();
    _sessionController.reset();
    _clearUserDataCache();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login({required String email, required String password}) async {
    await _prepareForNewAuthentication();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: true,
    );
    try {
      final response = await _authApi.login(
        LoginRequest(email: email, password: password),
      );
      await _completeAuthentication(response);
    } on ApiException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: error.statusCode == 401
            ? _strings.badCredentials
            : error.message,
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _prepareForNewAuthentication();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: true,
    );
    try {
      final response = await _authApi.register(
        RegisterRequest(
          name: name,
          email: email,
          password: password,
          preferredLanguage: _preferredLanguage,
        ),
      );
      await _completeAuthentication(response);
    } on ApiException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: error.message,
      );
    }
  }

  Future<void> googleLogin() async {
    await _prepareForNewAuthentication();
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: true,
    );

    final effectiveClientId = _googleWebClientId.isNotEmpty
        ? _googleWebClientId
        : _googleServerClientId;
    final effectiveServerClientId = _googleServerClientId.isNotEmpty
        ? _googleServerClientId
        : _googleWebClientId;

    if (effectiveClientId.isEmpty && effectiveServerClientId.isEmpty) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _strings.googleNotConfigured,
      );
      return;
    }

    try {
      final googleSignIn = GoogleSignIn(
        scopes: const ['email', 'profile'],
        clientId: kIsWeb && effectiveClientId.isNotEmpty
            ? effectiveClientId
            : null,
        serverClientId: effectiveServerClientId.isNotEmpty
            ? effectiveServerClientId
            : null,
      );
      try {
        await googleSignIn.disconnect();
      } on Exception {
        await googleSignIn.signOut();
      }
      final account = await googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(isLoading: false, clearError: true);
        return;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: _strings.googleIdTokenMissing,
        );
        return;
      }

      final response = await _authApi.googleLogin(
        GoogleLoginRequest(
          idToken: idToken,
          preferredLanguage: _preferredLanguage,
        ),
      );
      await _completeAuthentication(response);
    } on ApiException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: error.message,
      );
    } on PlatformException catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: _googleSignInErrorMessage(error),
      );
    } on Exception catch (error) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> changePreferredLanguage(String languageCode) async {
    final normalized = normalizeLanguageCode(languageCode);
    if (normalized == null) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authApi.updateLanguage(normalized);
      await _languageNotifier.setLanguage(user.preferredLanguage);
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (error) {
      state = state.copyWith(isLoading: false, errorMessage: error.message);
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clearToken();
    await _signOutGoogle();
    _sessionController.reset();
    _clearUserDataCache();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void setUser(UserModel user) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: user,
      isLoading: false,
      clearError: true,
    );
  }

  void clearError() {
    if (state.errorMessage == null) {
      return;
    }
    state = state.copyWith(clearError: true);
  }

  Future<void> _completeAuthentication(AuthResponse response) async {
    final token = response.accessToken.trim();
    if (token.isEmpty) {
      await _tokenStorage.clearToken();
      _clearUserDataCache();
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: _authTokenMissingMessage,
      );
      return;
    }

    _clearUserDataCache();
    await _tokenStorage.saveToken(token);
    await _languageNotifier.setLanguage(response.user.preferredLanguage);
    _sessionController.reset();
    state = AuthState(status: AuthStatus.authenticated, user: response.user);
  }

  Future<void> _prepareForNewAuthentication() async {
    await _tokenStorage.clearToken();
    _sessionController.reset();
    _clearUserDataCache();
  }

  String _googleSignInErrorMessage(PlatformException error) {
    final details = '${error.code} ${error.message ?? ''} ${error.details ?? ''}';
    final isDeveloperError =
        error.code == 'sign_in_failed' && details.contains('ApiException: 10');

    if (isDeveloperError) {
      return _strings.isRu
          ? 'Google вход не настроен. Проверьте package name и SHA-1 в Google Cloud.'
          : 'Google менен кируу жондолгон эмес. Google Cloud ичинен package name жана SHA-1 текшериңиз.';
    }

    return _strings.isRu
        ? 'Не удалось войти через Google. Попробуйте еще раз.'
        : 'Google менен кируу ишке ашкан жок. Кайра аракет кылыңыз.';
  }

  Future<void> _signOutGoogle() async {
    final googleSignIn = GoogleSignIn();
    try {
      await googleSignIn.disconnect();
    } on Exception {
      // Google may throw when there is no connected account.
    }
    try {
      await googleSignIn.signOut();
    } on Exception {
      // The account is already signed out.
    }
  }

  void _clearUserDataCache() {
    ref.invalidate(profileUserProvider);
    ref.invalidate(recordsProvider);
    ref.invalidate(categoriesProvider);
    ref.read(testProvider.notifier).clear();
  }
}
