import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 16,
    this.prefixIcon,
    this.suffixIcon,
  });
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final btnColor = widget.backgroundColor ?? AppColors.btnColor;
    final fgColor = widget.textColor ?? AppColors.textWhite;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    if (widget.isOutlined) {
      return SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height,
        child: OutlinedButton(
          onPressed: widget.isLoading ? null : widget.onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: btnColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
          child: _buildChild(btnColor),
        ),
      );
    }

    final darkerColor = Color.lerp(btnColor, AppColors.black, 0.18)!;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled
          ? null
          : (_) {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isDisabled
                ? null
                : LinearGradient(
                    colors: [btnColor, darkerColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            color: isDisabled ? AppColors.disabledBtnColor : null,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
          child: Center(
            child: _buildChild(
              isDisabled ? AppColors.disabledBtnText : fgColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (widget.isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: color),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.prefixIcon != null) ...[
          widget.prefixIcon!,
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: AppTypography.labelLarge.copyWith(
            color: widget.isOutlined ? color : color,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 8),
          widget.suffixIcon!,
        ],
      ],
    );
  }
}
