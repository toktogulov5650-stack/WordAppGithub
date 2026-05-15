import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/storage/token_storage.dart';
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
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
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
        state = AuthState(
          status: AuthStatus.unauthenticated,
          errorMessage: _strings.sessionExpired,
        );
      }
    });
    return AuthState.initial();
  }

  Future<void> checkSession() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    final token = await _tokenStorage.readToken();

    if (token == null || token.isEmpty) {
      _sessionController.reset();
      state = const AuthState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _authApi.getCurrentUser();
      await _languageNotifier.setLanguage(user.preferredLanguage);
      _sessionController.reset();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } on ApiException {
      await _tokenStorage.clearToken();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
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
    state = state.copyWith(isLoading: true, clearError: true);
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
    state = state.copyWith(isLoading: true, clearError: true);

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
    _sessionController.reset();
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
      state = AuthState(
        status: AuthStatus.unauthenticated,
        isLoading: false,
        errorMessage: _authTokenMissingMessage,
      );
      return;
    }

    await _tokenStorage.saveToken(token);
    await _languageNotifier.setLanguage(response.user.preferredLanguage);
    _sessionController.reset();
    state = AuthState(status: AuthStatus.authenticated, user: response.user);
  }
}
