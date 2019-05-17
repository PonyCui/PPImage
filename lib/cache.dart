part of 'pp_image.dart';

class PPImageCache {
  static PPImageCache shared = PPImageCache();

  final _cacheManager = DefaultCacheManager();

  Future<ImageProvider> fetchImage(PPImageItem item) async {
    if (item is PPNetworkImageItem) {
      final file = await _cacheManager.getFileFromCache(item.url);
      if (file != null) {
        return FileImage(file.file);
      }
    }
    return null;
  }

  Future storeImage(PPImageItem item, Uint8List fileBytes) async {
    if (item is PPNetworkImageItem) {
      await _cacheManager.putFile(item.url, fileBytes);
    }
  }
}
