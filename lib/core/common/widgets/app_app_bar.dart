import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Common gradient AppBar for use with `Scaffold.appBar`.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    required this.title,
    super.key,
    this.leading,
    this.actions,
    this.bottom,
    this.centerTitle = true,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final hasBackButton = leading == null && Navigator.of(context).canPop();

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.blueDarken3],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: centerTitle,
        leading:
            leading ??
            (hasBackButton
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                    color: AppColors.textWhite,
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null),
        title: Text(title),
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColors.textWhite,
          fontWeight: FontWeight.w700,
        ),
        actions: actions,
        bottom: bottom,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
    );
  }
}

/// Common gradient SliverAppBar for use inside `CustomScrollView`.
class AppSliverAppBar extends StatelessWidget {
  const AppSliverAppBar({
    required this.title,
    super.key,
    this.leading,
    this.actions,
    this.centerTitle = true,
    this.floating = true,
    this.snap = true,
    this.pinned = false,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool floating;
  final bool snap;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
      floating: floating,
      snap: snap,
      pinned: pinned,
      centerTitle: centerTitle,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.blueDarken3],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: AppColors.textWhite,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: const IconThemeData(color: AppColors.textWhite),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    );
  }
}
