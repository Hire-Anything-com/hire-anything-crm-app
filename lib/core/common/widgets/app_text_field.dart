import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.onChanged,
    this.onTap,
    this.focusNode,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.contentPadding,
  });
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final EdgeInsetsGeometry? contentPadding;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hasError = false;
  bool _isFocused = false;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _effectiveFocusNode.removeListener(_onFocusChange);
      _effectiveFocusNode = widget.focusNode ?? FocusNode();
      _effectiveFocusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _effectiveFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() => _isFocused = _effectiveFocusNode.hasFocus);
  }

  String? _wrappedValidator(String? value) {
    final result = widget.validator?.call(value);
    final hasError = result != null;
    if (hasError != _hasError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _hasError = hasError);
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _hasError
                ? AppColors.error.withAlpha(10)
                : _isFocused
                ? AppColors.primary.withAlpha(15)
                : AppColors.black.withAlpha(10),
            blurRadius: _hasError ? 4 : (_isFocused ? 12 : 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: widget.controller,
        validator: _wrappedValidator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        onTap: widget.onTap,
        focusNode: _effectiveFocusNode,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        inputFormatters: widget.inputFormatters,
        autovalidateMode: widget.autovalidateMode,
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: widget.hintText,
          labelText: widget.labelText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.grey400,
          ),
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          contentPadding:
              widget.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          filled: true,
          fillColor: _hasError ? AppColors.error.withAlpha(8) : AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.grey200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          errorStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.error,
            fontSize: 11,
            height: 1.2,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: widget.prefixIcon,
                )
              : null,
          prefixIconConstraints: const BoxConstraints(
            minHeight: 24,
            minWidth: 24,
          ),
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: widget.onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffixIcon,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minHeight: 24,
            minWidth: 24,
          ),
        ),
      ),
    );
  }
}
