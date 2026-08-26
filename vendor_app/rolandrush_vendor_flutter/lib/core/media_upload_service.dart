import 'dart:io';
import 'package:http/http.dart' as http;
import 'supabase_service.dart';

/// Uploads menu item media straight to R2 via a presigned URL obtained from
/// the `generate-upload-url` Edge Function. The Edge Function holds the R2
/// credentials (as function secrets) — this app never sees them, only a
/// short-lived presigned PUT URL for one specific object.
class MediaUploadException implements Exception {
  final String message;
  MediaUploadException(this.message);
  @override
  String toString() => message;
}

class MediaUploadService {
  static const int maxImageBytes = 10 * 1024 * 1024; // 10MB
  static const int maxVideoBytes = 50 * 1024 * 1024; // 50MB

  static const _allowedImageTypes = {'.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.webp': 'image/webp'};
  static const _allowedVideoTypes = {'.mp4': 'video/mp4', '.mov': 'video/quicktime'};

  /// Uploads [file] (an image or video already picked by the vendor) and
  /// returns the public R2 URL to store in menu_items.image_url/video_url.
  /// Throws [MediaUploadException] with a message safe to show the vendor.
  static Future<String> upload({required File file, required String mediaType}) async {
    final ext = _extensionOf(file.path);
    final contentType = mediaType == 'video' ? _allowedVideoTypes[ext] : _allowedImageTypes[ext];
    if (contentType == null) {
      throw MediaUploadException(mediaType == 'video'
          ? 'Unsupported video format. Use MP4 or MOV.'
          : 'Unsupported image format. Use JPG, PNG or WEBP.');
    }

    final bytes = await file.readAsBytes();
    final maxBytes = mediaType == 'video' ? maxVideoBytes : maxImageBytes;
    if (bytes.length > maxBytes) {
      throw MediaUploadException(mediaType == 'video'
          ? 'Video is too large (${(bytes.length / (1024 * 1024)).toStringAsFixed(1)}MB). Keep it under 50MB.'
          : 'Image is too large. Keep it under 10MB.');
    }

    final Map<String, dynamic> presign;
    try {
      final res = await SupabaseService.client.functions.invoke(
        'generate-upload-url',
        body: {
          'fileName': file.path.split(Platform.pathSeparator).last,
          'contentType': contentType,
          'mediaType': mediaType,
        },
      );
      if (res.status != 200 || res.data is! Map) {
        throw MediaUploadException('Could not prepare upload. Please try again.');
      }
      presign = Map<String, dynamic>.from(res.data as Map);
    } on MediaUploadException {
      rethrow;
    } catch (_) {
      throw MediaUploadException('Could not reach the upload service. Check your connection and try again.');
    }

    final uploadUrl = presign['uploadUrl'] as String?;
    final publicUrl = presign['publicUrl'] as String?;
    if (uploadUrl == null || publicUrl == null) {
      throw MediaUploadException('Upload service returned an unexpected response.');
    }

    try {
      final putRes = await http.put(
        Uri.parse(uploadUrl),
        headers: {'Content-Type': contentType},
        body: bytes,
      );
      if (putRes.statusCode < 200 || putRes.statusCode >= 300) {
        throw MediaUploadException('Upload failed (${putRes.statusCode}). Please try again.');
      }
    } on MediaUploadException {
      rethrow;
    } catch (_) {
      throw MediaUploadException('Upload failed. Check your connection and try again.');
    }

    return publicUrl;
  }

  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '';
    return path.substring(dot).toLowerCase();
  }
}
