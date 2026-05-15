import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, success, danger, warning }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.leading,
    this.fullWidth = true,
    this.height = 54,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Widget? leading;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final style = _styleForVariant(variant);
    final isDisabled = onPressed == null && !isLoading;
    final borderRadius = BorderRadius.circular(18);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isDisabled ? 0.55 : 1,
      child: Container(
        width: fullWidth ? double.infinity : null,
        height: height,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: borderRadius,
          border: Border.all(color: style.borderColor),
          boxShadow: [
            BoxShadow(
              color: style.shadowColor,
              blurRadius: style.shadowBlur,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: isLoading ? null : onPressed,
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          style.foregroundColor,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (leading != null) ...[
                            leading!,
                            const SizedBox(width: 10),
                          ] else if (icon != null) ...[
                            Icon(icon, color: style.foregroundColor, size: 19),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: style.foregroundColor,
                                    fontSize: 15,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  _ButtonStyle _styleForVariant(AppButtonVariant variant) {
    return switch (variant) {
      AppButtonVariant.primary => const _ButtonStyle(
        backgroundColor: AppColors.textDark,
        foregroundColor: Colors.white,
        borderColor: AppColors.textDark,
        shadowColor: AppColors.shadowStrong,
        shadowBlur: 18,
      ),
      AppButtonVariant.secondary => const _ButtonStyle(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.textDark,
        borderColor: AppColors.border,
        shadowColor: AppColors.shadowSoft,
        shadowBlur: 14,
      ),
      AppButtonVariant.success => const _ButtonStyle(
        backgroundColor: AppColors.successSurface,
        foregroundColor: AppColors.successDark,
        borderColor: Color(0xFFBBF7D0),
        shadowColor: Color(0x0822C55E),
        shadowBlur: 14,
      ),
      AppButtonVariant.danger => const _ButtonStyle(
        backgroundColor: AppColors.errorSurface,
        foregroundColor: AppColors.errorDark,
        borderColor: Color(0xFFFECACA),
        shadowColor: Color(0x08EF4444),
        shadowBlur: 14,
      ),
      AppButtonVariant.warning => const _ButtonStyle(
        backgroundColor: AppColors.warningSurface,
        foregroundColor: AppColors.warningDark,
        borderColor: Color(0xFFFDE68A),
        shadowColor: Color(0x08F59E0B),
        shadowBlur: 14,
      ),
    };
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.shadowBlur,
  });

  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;
}
