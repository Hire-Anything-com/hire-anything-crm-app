import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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
    this.suggestionsCallback,
    this.suggestionBuilder,
    this.onSuggestionSelected,
    this.suggestionLimit = 3,
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
  final FutureOr<Iterable<String>> Function(String)? suggestionsCallback;
  final Widget Function(BuildContext, String)? suggestionBuilder;
  final void Function(String)? onSuggestionSelected;
  final int suggestionLimit;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final ValueNotifier<bool> _hasErrorNotifier;
  late final ValueNotifier<bool> _isFocusedNotifier;
  late FocusNode _effectiveFocusNode;

  @override
  void initState() {
    super.initState();
    _hasErrorNotifier = ValueNotifier<bool>(false);
    _isFocusedNotifier = ValueNotifier<bool>(false);
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
    _isFocusedNotifier.value = _effectiveFocusNode.hasFocus;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _effectiveFocusNode.removeListener(_onFocusChange);
      _effectiveFocusNode = widget.focusNode ?? FocusNode();
      _effectiveFocusNode.addListener(_onFocusChange);
      _isFocusedNotifier.value = _effectiveFocusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _effectiveFocusNode.dispose();
    _hasErrorNotifier.dispose();
    _isFocusedNotifier.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) _isFocusedNotifier.value = _effectiveFocusNode.hasFocus;
  }

  String? _wrappedValidator(String? value) {
    final result = widget.validator?.call(value);
    final hasError = result != null;
    if (hasError != _hasErrorNotifier.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hasErrorNotifier.value = hasError;
      });
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _hasErrorNotifier,
      builder: (context, hasError, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isFocusedNotifier,
          builder: (context, isFocused, __) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: hasError
                        ? AppColors.error.withAlpha(10)
                        : isFocused
                        ? AppColors.primary.withAlpha(15)
                        : AppColors.black.withAlpha(10),
                    blurRadius: hasError ? 4 : (isFocused ? 12 : 8),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Builder(
                builder: (context) {
                  final inputDecoration = InputDecoration(
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
                        const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                    filled: true,
                    fillColor: hasError
                        ? AppColors.error.withAlpha(8)
                        : AppColors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.grey200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.error,
                        width: 1.5,
                      ),
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
                  );

                  if (widget.suggestionsCallback != null) {
                    return TypeAheadFormField<String>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: widget.controller,
                        focusNode: _effectiveFocusNode,
                        keyboardType: widget.keyboardType,
                        textInputAction: widget.textInputAction,
                        enabled: widget.enabled,
                        maxLines: widget.maxLines,
                        onTap: widget.onTap,
                        onChanged: widget.onChanged,
                        inputFormatters: widget.inputFormatters,
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        cursorColor: AppColors.primary,
                        decoration: inputDecoration,
                      ),
                      suggestionsCallback: (pattern) async {
                        final res = await widget.suggestionsCallback!(pattern);
                        final list = res.toList();
                        return list.take(widget.suggestionLimit);
                      },
                      itemBuilder: (context, String suggestion) =>
                          widget.suggestionBuilder != null
                          ? widget.suggestionBuilder!(context, suggestion)
                          : ListTile(
                              title: Text(
                                suggestion,
                                style: AppTypography.bodyMedium,
                              ),
                            ),
                      onSuggestionSelected: (String suggestion) {
                        if (widget.controller != null)
                          widget.controller!.text = suggestion;
                        widget.onSuggestionSelected?.call(suggestion);
                      },
                      validator: _wrappedValidator,
                      autovalidateMode: widget.autovalidateMode,
                      suggestionsBoxDecoration: SuggestionsBoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        elevation: 4,
                        color: Colors.white,
                      ),
                    );
                  }

                  return TextFormField(
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
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: inputDecoration,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
