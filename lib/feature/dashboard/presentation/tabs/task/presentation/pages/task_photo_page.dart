import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hireanythingbooking/core/core.dart';
import 'package:hireanythingbooking/core/utils/cloudinary_service.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_cubit.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/cubit/task_state.dart';
import 'package:hireanythingbooking/feature/dashboard/presentation/tabs/task/presentation/pages/task_otp_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class TaskPhotoPage extends StatelessWidget {
  const TaskPhotoPage({super.key});

  static const _maxPhotos = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Upload Photo'),
      body: BlocConsumer<TaskCubit, TaskState>(
        listenWhen: (prev, curr) =>
            prev.isUploadingPhotos && !curr.isUploadingPhotos,
        listener: (context, state) {
          if (state.photoUploadError != null) {
            AppSnackBar.show(
              context,
              message: state.photoUploadError!,
              type: SnackBarType.error,
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: context.read<TaskCubit>(),
                  child: const TaskOtpPage(),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final photos = state.photoPaths;
          final isUploading = state.isCloudinaryUploading;
          final isSubmitting = state.isUploadingPhotos;
          // canAdd: true if we haven't hit the max and nothing is uploading right now
          final canAdd = photos.length < _maxPhotos && !isUploading;
          final hasPhotos = photos.isNotEmpty;
          // show the strip if we have confirmed photos OR a photo is mid-upload
          final showStrip = hasPhotos || isUploading;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppSpacing.h8,

                // ── Header icon ──────────────────────────────────────────
                Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isUploading
                        ? _PulsingCloudIcon(key: const ValueKey('uploading'))
                        : Container(
                            key: const ValueKey('idle'),
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
                ),
                AppSpacing.h16,

                // ── Title ────────────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    isUploading
                        ? 'Uploading to Cloud...'
                        : hasPhotos
                        ? '${photos.length} ${photos.length == 1 ? 'Photo' : 'Photos'} Added!'
                        : 'Upload Work Photos',
                    key: ValueKey(
                      isUploading
                          ? 'uploading'
                          : hasPhotos
                          ? 'has_${photos.length}'
                          : 'empty',
                    ),
                    style: AppTypography.headlineSmall.copyWith(
                      color: isUploading
                          ? AppColors.textSecondary
                          : hasPhotos
                          ? AppColors.primary
                          : AppColors.grey900,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  isUploading
                      ? 'Please wait while your photo is being saved'
                      : 'Upload at least 1 photo to complete the task',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.grey500,
                  ),
                  textAlign: TextAlign.center,
                ),
                AppSpacing.h24,

                // ── Big upload / shimmer box — responsive, identical size ─
                if (photos.length < _maxPhotos)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive height: ~45% of available width, clamped
                      // so the card looks consistent on every mobile size
                      // (small phones → tablets) and matches the shimmer box.
                      final boxHeight = (constraints.maxWidth * 0.45).clamp(
                        150.0,
                        200.0,
                      );
                      return SizedBox(
                        height: boxHeight,
                        width: double.infinity,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: isUploading
                              ? const _CloudinaryShimmerBox(
                                  key: ValueKey('shimmer'),
                                )
                              : GestureDetector(
                                  key: const ValueKey('add_box'),
                                  onTap: () => _showPickerOptions(context),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(8),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.primary.withAlpha(60),
                                        width: 1.5,
                                        strokeAlign:
                                            BorderSide.strokeAlignInside,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withAlpha(
                                              20,
                                            ),
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
                                          style: AppTypography.titleSmall
                                              .copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        AppSpacing.h4,
                                        Text(
                                          'Tap to add images  •  ${photos.length}/$_maxPhotos',
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.grey500,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                // ── Photo strip ─────────────────────────────────────────
                if (showStrip) ...[
                  AppSpacing.h24,
                  SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.zero,
                      itemCount:
                          photos.length +
                          (isUploading ? 1 : 0) +
                          (canAdd && hasPhotos ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        // Confirmed photos
                        if (index < photos.length) {
                          return SizedBox(
                            width: 110,
                            height: 110,
                            child: _PhotoTile(
                              path: photos[index],
                              onRemove: isUploading || isSubmitting
                                  ? null
                                  : () => context.read<TaskCubit>().removePhoto(
                                      index,
                                    ),
                            ),
                          );
                        }
                        // Shimmer tile for the in-flight photo
                        if (isUploading && index == photos.length) {
                          return SizedBox(
                            width: 110,
                            height: 110,
                            child: _UploadingPhotoTile(
                              path: state.pendingPhotoPath,
                            ),
                          );
                        }
                        // "Add more" tile
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

                AppSpacing.h32,

                // ── Continue button ──────────────────────────────────────
                SafeArea(
                  child: AppButton(
                    text: isSubmitting
                        ? 'Submitting...'
                        : isUploading
                        ? 'Uploading...'
                        : 'Continue',
                    backgroundColor:
                        (hasPhotos && !isSubmitting && !isUploading)
                        ? AppColors.primary
                        : null,
                    onPressed: (hasPhotos && !isSubmitting && !isUploading)
                        ? () => context.read<TaskCubit>().submitTaskPhotos()
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
                // ListTile(
                //   leading: Container(
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: AppColors.secondary.withAlpha(25),
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Icon(AppIcons.image, color: AppColors.secondary),
                //   ),
                //   title: const Text('Gallery'),
                //   subtitle: const Text('Choose from gallery'),
                //   onTap: () {
                //     Navigator.of(bottomSheetContext).pop();
                //     _pickImage(context, ImageSource.gallery);
                //   },
                // ),
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
    if (picked == null || !context.mounted) return;

    DebugLogger.log('📸', 'TASK_PHOTO', 'Photo picked: ${picked.path}');

    // Mark Cloudinary upload as in-progress BEFORE uploading, store path for preview
    context.read<TaskCubit>().setCloudinaryUploading(
      value: true,
      path: picked.path,
    );

    final result = await CloudinaryService.uploadImage(picked.path);

    if (!context.mounted) return;

    if (result != null) {
      DebugLogger.log(
        '🔗',
        'TASK_PHOTO',
        'Cloudinary URL: ${result.secureUrl}',
      );
      DebugLogger.log(
        '📐',
        'TASK_PHOTO',
        'public_id: ${result.publicId} | ${result.width}x${result.height}',
      );
      // Atomically add path + URL only on success
      context.read<TaskCubit>().addPhotoWithCloudinaryUrl(
        picked.path,
        result.secureUrl,
      );
    } else {
      DebugLogger.error('TASK_PHOTO', 'Upload failed for: ${picked.path}');
      // Clear uploading state and show error — do NOT add the photo
      context.read<TaskCubit>().setCloudinaryUploading(value: false);
      AppSnackBar.show(
        context,
        message: 'Failed to upload photo. Please try again.',
        type: SnackBarType.error,
      );
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
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(path), fit: BoxFit.cover),
          if (onRemove != null)
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

// ─── Uploading Photo Tile (shimmer wave over real image) ─────────────────────

class _UploadingPhotoTile extends StatefulWidget {
  const _UploadingPhotoTile({this.path});
  final String? path;

  @override
  State<_UploadingPhotoTile> createState() => _UploadingPhotoTileState();
}

class _UploadingPhotoTileState extends State<_UploadingPhotoTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Real image preview (or grey placeholder if path unavailable)
          if (widget.path != null)
            Image.file(File(widget.path!), fit: BoxFit.cover)
          else
            Container(color: AppColors.grey200),

          // Animated shimmer sweep overlay
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) => LinearGradient(
                  begin: Alignment(-2 + 4 * _ctrl.value, 0),
                  end: Alignment(-1 + 4 * _ctrl.value, 0),
                  colors: const [
                    Color(0x00FFFFFF),
                    Color(0x55FFFFFF),
                    Color(0x00FFFFFF),
                  ],
                ).createShader(bounds),
                child: Container(color: Colors.white),
              );
            },
          ),

          // Semi-transparent dark overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(90),
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Upload icon + "Uploading" label
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Uploading',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shimmer box shown in the big upload area while Cloudinary is uploading ──

class _CloudinaryShimmerBox extends StatefulWidget {
  const _CloudinaryShimmerBox({super.key});

  @override
  State<_CloudinaryShimmerBox> createState() => _CloudinaryShimmerBoxState();
}

class _CloudinaryShimmerBoxState extends State<_CloudinaryShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = _ctrl.value; // 0→1→0 (reverse: true)
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withAlpha((8 + (25 * t)).round()),
            border: Border.all(
              color: AppColors.primary.withAlpha((40 + (80 * t)).round()),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Pulsing cloud icon
              ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1.1).animate(
                  CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
                ),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha((20 + (30 * t)).round()),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),
              AppSpacing.h12,
              Text(
                'Saving to cloud...',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              AppSpacing.h4,
              // Animated dots
              _AnimatedDots(),
            ],
          ),
        );
      },
    );
  }
}

// ─── Animated "..." dots ─────────────────────────────────────────────────────

class _AnimatedDots extends StatefulWidget {
  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  static const _steps = 4;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final step = (_ctrl.value * _steps).floor();
        final dots = '.' * (step % (_steps) + 1);
        return Text(
          dots,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.primary,
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }
}

// ─── Pulsing cloud icon for header ───────────────────────────────────────────

class _PulsingCloudIcon extends StatefulWidget {
  const _PulsingCloudIcon({super.key});

  @override
  State<_PulsingCloudIcon> createState() => _PulsingCloudIconState();
}

class _PulsingCloudIconState extends State<_PulsingCloudIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.cloud_upload_outlined,
          size: 40,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
