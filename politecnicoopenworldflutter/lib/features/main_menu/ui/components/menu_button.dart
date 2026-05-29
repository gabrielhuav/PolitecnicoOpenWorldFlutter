import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../ui/theme/theme_extensions.dart';

class MenuButton extends ConsumerWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;

  const MenuButton({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.appTheme;

    // Colores efectivos según variante
    final Color bg = isSecondary ? Colors.transparent : theme.buttonPrimary;
    final Color fg = isSecondary ? theme.textPrimary : theme.buttonPrimaryText;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading ? const SizedBox.shrink() : Icon(icon, color: fg),
        label: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: fg,
                  strokeWidth: 3,
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: fg,
                ),
              ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: isSecondary ? 0 : 5,
          side: isSecondary
              ? BorderSide(color: theme.textTertiary, width: 2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          disabledBackgroundColor: isSecondary
              ? Colors.transparent
              : theme.buttonPrimary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
