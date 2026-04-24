import 'package:dio/dio.dart';
import 'package:hireanythingbooking/core/utils/debug_logger.dart';

/// Cloudinary configuration constants.
///
/// ⚠️  SECURITY: Only [cloudName] and [apiKey] are safe for client-side code.
/// The API secret must never be stored in the app — use unsigned upload presets
/// for all mobile uploads.
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'dfzhndoza';
  static const String apiKey = '192193338921635';

  /// Unsigned upload preset — create this in:
  /// Cloudinary Dashboard → Settings → Upload → Upload presets → Add preset
  /// Set "Signing mode" to "Unsigned" and name it [uploadPreset].
  static const String uploadPreset = 'partner';

  static const String _baseUploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName';

  /// Returns the image upload endpoint URL.
  static String get imageUploadUrl => '$_baseUploadUrl/image/upload';

  /// Returns the raw/file upload endpoint URL.
  static String get rawUploadUrl => '$_baseUploadUrl/raw/upload';

  /// Builds a Cloudinary delivery URL for a given [publicId] with optional
  /// transformations.
  ///
  /// Example:
  /// ```dart
  /// CloudinaryConfig.buildDeliveryUrl('task_photos/abc123',
  ///   width: 800, quality: 'auto', format: 'webp');
  /// ```
  static String buildDeliveryUrl(
    String publicId, {
    int? width,
    int? height,
    String? quality,
    String? format,
    String? crop,
  }) {
    final transformations = <String>[];

    if (width != null) transformations.add('w_$width');
    if (height != null) transformations.add('h_$height');
    if (crop != null) transformations.add('c_$crop');
    if (quality != null) transformations.add('q_$quality');
    if (format != null) transformations.add('f_$format');

    final transform = transformations.isNotEmpty
        ? '${transformations.join(',')}/'
        : '';

    return 'https://res.cloudinary.com/$cloudName/image/upload/$transform$publicId';
  }
}

/// Result of a Cloudinary upload operation.
class CloudinaryUploadResult {
  const CloudinaryUploadResult({
    required this.secureUrl,
    required this.publicId,
    required this.format,
    required this.bytes,
    required this.width,
    required this.height,
  });

  /// The HTTPS URL to the uploaded asset.
  final String secureUrl;

  /// The public identifier of the uploaded asset.
  final String publicId;

  /// The file format (e.g. `jpg`, `png`).
  final String format;

  /// The file size in bytes.
  final int bytes;

  /// The image width in pixels.
  final int width;

  /// The image height in pixels.
  final int height;

  @override
  String toString() =>
      'CloudinaryUploadResult(publicId: $publicId, url: $secureUrl, '
      '${width}x$height, $bytes bytes)';
}

/// Service for uploading files to Cloudinary using unsigned upload presets.
///
/// Usage:
/// ```dart
/// final result = await CloudinaryService.uploadImage('/path/to/photo.jpg');
/// if (result != null) print(result.secureUrl);
/// ```
class CloudinaryService {
  CloudinaryService._();

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      validateStatus: (_) => true,
    ),
  );

  /// Uploads an image file at [filePath] to Cloudinary.
  ///
  /// Optionally specify a [folder] to organise assets in Cloudinary
  /// (e.g. `'task_photos'`).
  ///
  /// Returns a [CloudinaryUploadResult] on success, or `null` on failure.
  static Future<CloudinaryUploadResult?> uploadImage(
    String filePath, {
    String folder = 'task_photos',
  }) async {
    DebugLogger.log('☁️', 'CLOUDINARY', 'Starting upload: $filePath');

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'upload_preset': CloudinaryConfig.uploadPreset,
        'api_key': CloudinaryConfig.apiKey,
        if (folder.isNotEmpty) 'folder': folder,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        CloudinaryConfig.imageUploadUrl,
        data: formData,
      );

      final statusCode = response.statusCode ?? 0;
      final data = response.data;

      if (statusCode != 200 || data == null) {
        final error = data?['error'] as Map<String, dynamic>?;
        final errorMsg =
            error?['message'] as String? ?? 'HTTP $statusCode — upload failed';
        DebugLogger.error('CLOUDINARY', 'Upload failed: $errorMsg');
        return null;
      }

      final result = CloudinaryUploadResult(
        secureUrl: data['secure_url'] as String? ?? '',
        publicId: data['public_id'] as String? ?? '',
        format: data['format'] as String? ?? '',
        bytes: data['bytes'] as int? ?? 0,
        width: data['width'] as int? ?? 0,
        height: data['height'] as int? ?? 0,
      );

      DebugLogger.log(
        '✅',
        'CLOUDINARY',
        'Upload successful → ${result.secureUrl}',
      );
      DebugLogger.log(
        '📐',
        'CLOUDINARY',
        'public_id: ${result.publicId} | '
            '${result.width}x${result.height} | ${result.bytes} bytes',
      );

      return result;
    } on DioException catch (e) {
      DebugLogger.error('CLOUDINARY', 'DioException: ${e.message}');
      return null;
    } on Exception catch (e) {
      DebugLogger.error('CLOUDINARY', 'Unexpected error: $e');
      return null;
    }
  }

  /// Uploads multiple images concurrently and returns all successful results.
  static Future<List<CloudinaryUploadResult>> uploadImages(
    List<String> filePaths, {
    String folder = 'task_photos',
  }) async {
    DebugLogger.log(
      '☁️',
      'CLOUDINARY',
      'Uploading ${filePaths.length} image(s)...',
    );

    final futures = filePaths
        .map((path) => uploadImage(path, folder: folder))
        .toList();

    final results = await Future.wait(futures);

    final successful = results.whereType<CloudinaryUploadResult>().toList();

    DebugLogger.log(
      '📊',
      'CLOUDINARY',
      '${successful.length}/${filePaths.length} uploads succeeded',
    );

    for (final r in successful) {
      DebugLogger.log('🔗', 'CLOUDINARY', r.secureUrl);
    }

    return successful;
  }
}
