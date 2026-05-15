import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../session/session_controller.dart';
import '../language/language_provider.dart';
import '../../features/auth/presentation/language_selection_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/explanations/presentation/word_explanation_screen.dart';
import '../../features/explanations/presentation/words_by_category_screen.dart';
import '../../features/shell/presentation/main_shell_screen.dart';
import '../../features/tests/presentation/result_screen.dart';
import '../../features/tests/presentation/test_screen.dart';
import '../../features/tests/presentation/unknown_words_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final tabIndex =
              int.tryParse(state.uri.queryParameters['tab'] ?? '') ?? 0;
          return MainShellScreen(initialIndex: tabIndex);
        },
        routes: [
          GoRoute(
            path: 'test/:categoryId',
            builder: (context, state) {
              final categoryId =
                  int.tryParse(state.pathParameters['categoryId'] ?? '') ?? 0;
              return TestScreen(categoryId: categoryId);
            },
          ),
          GoRoute(
            path: 'result/:testSessionId',
            builder: (context, state) {
              final testSessionId =
                  int.tryParse(state.pathParameters['testSessionId'] ?? '') ??
                  0;
              return ResultScreen(testSessionId: testSessionId);
            },
          ),
          GoRoute(
            path: 'unknown-words/:testSessionId',
            builder: (context, state) {
              final testSessionId =
                  int.tryParse(state.pathParameters['testSessionId'] ?? '') ??
                  0;
              return UnknownWordsScreen(testSessionId: testSessionId);
            },
          ),
          GoRoute(
            path: 'explanations/category/:categoryId',
            builder: (context, state) {
              final categoryId =
                  int.tryParse(state.pathParameters['categoryId'] ?? '') ?? 0;
              return WordsByCategoryScreen(categoryId: categoryId);
            },
          ),
          GoRoute(
            path: 'word-explanation/:wordId',
            builder: (context, state) {
              final wordId =
                  int.tryParse(state.pathParameters['wordId'] ?? '') ?? 0;
              return WordExplanationScreen(wordId: wordId);
            },
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final languageState = ref.read(languageProvider);
      final sessionController = ref.read(sessionControllerProvider);
      final isOnAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isLanguageRoute = state.matchedLocation == '/language';
      final isSplash = state.matchedLocation == '/splash';

      if (languageState.isLoading) {
        return isSplash ? null : '/splash';
      }

      if (!languageState.hasLanguage) {
        return isLanguageRoute ? null : '/language';
      }

      if (isLanguageRoute) {
        return authState.status == AuthStatus.authenticated ? '/' : '/login';
      }

      if (sessionController.isUnauthorized) {
        return isOnAuthRoute ? null : '/login';
      }

      if (authState.status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      if (authState.status == AuthStatus.unauthenticated) {
        return isOnAuthRoute ? null : '/login';
      }

      if (isSplash || isOnAuthRoute) {
        return '/';
      }

      return null;
    },
  );

  ref.listen<AuthState>(authProvider, (previous, next) {
    router.refresh();
  });
  ref.listen<LanguageState>(languageProvider, (previous, next) {
    router.refresh();
  });
  ref.listen<SessionController>(sessionControllerProvider, (previous, next) {
    router.refresh();
  });

  ref.onDispose(router.dispose);
  return router;
});
