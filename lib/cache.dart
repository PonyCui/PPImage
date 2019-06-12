part of 'pp_image.dart';

class PPImageCache {
  static PPImageCache shared = PPImageCache();

  final _cacheManager = DefaultCacheManager();

  Future<ImageProvider> fetchImage(String url) async {
    final file = await _cacheManager.getFileFromCache(url);
    if (file != null) {
      return FileImage(file.file);
    }
    return null;
  }

  Future storeImage(String url, Uint8List fileBytes) async {
    if (url is String && url.isNotEmpty) {
      await _cacheManager.putFile(url, fileBytes);
    }
  }
}
