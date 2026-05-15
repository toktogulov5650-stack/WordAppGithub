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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authProvider.notifier).clearError());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref.read(authProvider.notifier).register(
      name: _nameController.text.trim(),
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
      title: strings.register,
      topAction: IconButton(
        onPressed: authState.isLoading
            ? null
            : () {
                ref.read(authProvider.notifier).clearError();
                context.pop();
              },
        icon: const Icon(Icons.arrow_back_rounded),
        style: IconButton.styleFrom(
          backgroundColor: AppColors.card,
          foregroundColor: AppColors.textDark,
          side: const BorderSide(color: AppColors.border),
        ),
      ),
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
                controller: _nameController,
                label: strings.name,
                hintText: strings.enterName,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                prefixIcon: Icons.person_outline_rounded,
                validator: _validateName,
              ),
              const SizedBox(height: 12),
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
                hintText: strings.newPassword,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enableSuggestions: false,
                autocorrect: false,
                validator: _validatePassword,
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
              const SizedBox(height: 12),
              AppTextField(
                controller: _confirmPasswordController,
                label: strings.repeatPassword,
                obscureText: _obscureConfirmPassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newPassword],
                enableSuggestions: false,
                autocorrect: false,
                validator: _validateConfirmPassword,
                onFieldSubmitted: (_) => _submit(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppButton(
                label: strings.register,
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
        prompt: strings.haveAccount,
        actionLabel: strings.login,
        onPressed: authState.isLoading
            ? null
            : () {
                ref.read(authProvider.notifier).clearError();
                context.pop();
              },
      ),
    );
  }

  String? _validateName(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).enterName;
    }
    return null;
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

  String? _validateConfirmPassword(String? value) {
    if ((value ?? '').isEmpty) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).repeatPasswordError;
    }
    if (value != _passwordController.text) {
      return AppStrings.fromCode(ref.read(languageProvider).languageCode).passwordsDoNotMatch;
    }
    return null;
  }
}
