import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/task/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/task/pages/task_otp_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class TaskPhotoPage extends StatelessWidget {
  const TaskPhotoPage({super.key});

  static const _maxPhotos = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Upload Photo'),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          final photos = state.photoPaths;
          final canAdd = photos.length < _maxPhotos;
          final hasPhotos = photos.isNotEmpty;

          return Padding(
            padding: AppSpacing.p16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.h16,

                // Icon
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      hasPhotos
                          ? Icons.check_circle_outline_rounded
                          : Icons.camera_alt_outlined,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                AppSpacing.h16,

                Text(
                  hasPhotos
                      ? '${photos.length} ${photos.length == 1 ? 'Photo' : 'Photos'} Added!'
                      : 'Upload Work Photos',
                  style: AppTypography.headlineSmall.copyWith(
                    color: hasPhotos ? AppColors.primary : AppColors.grey900,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.h4,
                Text(
                  'Upload at least 1 photo to complete the task',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.h24,

                // Big upload area (dashed border)
                if (canAdd)
                  GestureDetector(
                    onTap: () => _showPickerOptions(context),
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withAlpha(60),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_rounded,
                              size: 32,
                              color: AppColors.primary,
                            ),
                          ),
                          AppSpacing.h12,
                          Text(
                            '📷  Upload Photos',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          AppSpacing.h4,
                          Text(
                            'Tap to add images  •  ${photos.length}/$_maxPhotos',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (hasPhotos) ...[
                  AppSpacing.h24,

                  // Horizontal image strip
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length + (canAdd ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index < photos.length) {
                          return SizedBox(
                            width: 110,
                            height: 110,
                            child: _PhotoTile(
                              path: photos[index],
                              onRemove: () =>
                                  context.read<TaskCubit>().removePhoto(index),
                            ),
                          );
                        }
                        // Add more button
                        return SizedBox(
                          width: 110,
                          height: 110,
                          child: _AddPhotoTile(
                            onTap: () => _showPickerOptions(context),
                          ),
                        );
                      },
                    ),
                  ),
                ],

                const Spacer(),

                SafeArea(
                  child: AppButton(
                    text: 'Continue',
                    backgroundColor: hasPhotos ? AppColors.primary : null,
                    onPressed: hasPhotos
                        ? () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider.value(
                                value: context.read<TaskCubit>(),
                                child: const TaskOtpPage(),
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
                AppSpacing.h8,
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                AppSpacing.h16,
                Text('Upload Photo', style: AppTypography.titleMedium),
                AppSpacing.h16,
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(AppIcons.camera, color: AppColors.primary),
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(AppIcons.image, color: AppColors.secondary),
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();
                    _pickImage(context, ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    var status = await permission.status;

    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showSettingsDialog(context, source);
      }
      return;
    }

    if (!status.isGranted) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message:
              'Permission denied. Cannot access ${source == ImageSource.camera ? 'camera' : 'gallery'}.',
          type: SnackBarType.warning,
        );
      }
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked != null && context.mounted) {
      context.read<TaskCubit>().addPhoto(picked.path);
    }
  }

  void _showSettingsDialog(BuildContext context, ImageSource source) {
    final label = source == ImageSource.camera ? 'Camera' : 'Gallery';
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('$label Permission Required'),
        content: Text(
          '$label access has been permanently denied. '
          'Please open settings and enable it manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}

// ─── Photo Tile ──────────────────────────────────────────────────────────────

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(path), fit: BoxFit.cover),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Add Photo Tile ──────────────────────────────────────────────────────────

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(AppIcons.add, color: AppColors.primary, size: 28),
            AppSpacing.h4,
            Text(
              'Add',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
