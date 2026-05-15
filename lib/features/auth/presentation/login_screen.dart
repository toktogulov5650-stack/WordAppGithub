import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/language/app_strings.dart';
import '../../../core/language/language_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/google_mark.dart';
import '../providers/auth_provider.dart';
import 'widgets/auth_screen_frame.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).clearError());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  Future<void> _googleLogin() async {
    await ref.read(authProvider.notifier).googleLogin();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final strings = AppStrings.fromCode(ref.watch(languageProvider).languageCode);

    return AuthScreenFrame(
      title: strings.login,
      form: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (authState.errorMessage != null) ...[
                AuthErrorBanner(message: authState.errorMessage!),
                const SizedBox(height: 16),
              ],
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'you@example.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                enableSuggestions: false,
                autocorrect: false,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _passwordController,
                label: strings.password,
                hintText: strings.yourPassword,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                enableSuggestions: false,
                autocorrect: false,
                validator: _validatePassword,
                onFieldSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: strings.login,
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? null : _submit,
              ),
              const SizedBox(height: 16),
              AuthDivider(label: strings.or),
              const SizedBox(height: 16),
              AppButton(
                label: strings.googleLogin,
                variant: AppButtonVariant.secondary,
                leading: const GoogleMark(),
                onPressed: authState.isLoading ? null : _googleLogin,
              ),
            ],
          ),
        ),
      ),
      footer: AuthSwitchRow(
        prompt: strings.noAccount,
        actionLabel: strings.register,
        onPressed: authState.isLoading
            ? null
            : () {
                ref.read(authProvider.notifier).clearError();
                context.push('/register');
              },
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).enterEmail;
    }

    const pattern = r'^[^@]+@[^@]+\.[^@]+$';
    if (!RegExp(pattern).hasMatch(email)) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).validEmail;
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).enterPassword;
    }

    if (password.length < 6) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).minPassword;
    }

    return null;
  }
}
