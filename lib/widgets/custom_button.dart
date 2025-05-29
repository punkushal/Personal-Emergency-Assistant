import 'package:flutter/material.dart';
import 'package:personal_emergency_assistant/constants/app_themes.dart';
import 'package:personal_emergency_assistant/widgets/loading_indicator.dart';

enum ButtonVariant { filled, outlined, text }

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.variant,
    required this.isLoading,
    this.icon,
    this.backgroundColor,
    this.txtColor,
    this.width,
    this.height,
  });
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? txtColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    //Determine colors based on variant
    Color getBgColor() {
      if (backgroundColor != null) return backgroundColor!;

      switch (variant) {
        case ButtonVariant.filled:
          return theme.primaryColor;
        case ButtonVariant.outlined:
          return Colors.transparent;
        case ButtonVariant.text:
          return Colors.transparent;
      }
    }

    Color getTxtColor() {
      if (txtColor != null) return txtColor!;
      switch (variant) {
        case ButtonVariant.filled:
          return Colors.white;
        case ButtonVariant.outlined:
          return theme.primaryColor;
        case ButtonVariant.text:
          return theme.primaryColor;
      }
    }

    BorderSide? getBorder() {
      switch (variant) {
        case ButtonVariant.outlined:
          return BorderSide(color: theme.primaryColor);
        default:
          return null;
      }
    }

    Widget buildContent() {
      if (isLoading) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIndicator(color: getTxtColor(), size: 16),
            const SizedBox(width: 8),
            Text('Loading...'),
          ],
        );
      }

      if (icon != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(text),
          ],
        );
      }

      return Text(text);
    }

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getTxtColor(),
          textStyle: AppThemes.buttonTextStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: getBorder() ?? BorderSide.none,
          ),
          elevation: variant == ButtonVariant.filled ? 2 : 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: buildContent(),
      ),
    );
  }
}
