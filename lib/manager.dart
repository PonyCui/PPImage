part of 'pp_image.dart';

enum PPImageDownloadPriority { high, low }

class PPErrorMessage {
  int code;
  String message;
  PPErrorMessage({this.code, this.message});
}

typedef PPImageDownloadLogCallback = void Function(String log);
typedef PPImageDownloadResultCallback = void Function(
    Uint8List data, PPErrorMessage error);

/// 图片下载管理器
///
/// 基本规则：download 默认低优先级，加在等待队列尾部，高优先级会加入到等待队列头部
/// 默认并发数量为 10，设置并发数见：[configuration]
class PPImageDownloadManager {
  static final shared = PPImageDownloadManager();
  int _maxDownloadCount = 10;
  PPImageDownloadLogCallback _logCallback;

  configuration(int maxCount, {PPImageDownloadLogCallback logCallback}) {
    _maxDownloadCount = maxCount;
    _logCallback = logCallback;
  }

  List<String> _downloadingQueue = [];
  List<String> _waitingQueue = [];
  Map<String, List<Function>> _downloadObservers = {};

  isDownloading(String url) {
    if (_downloadingQueue.contains(url)) {
      return true;
    }
    return false;
  }

  download(String url,
      {PPImageDownloadResultCallback callback,
      PPImageDownloadPriority priority: PPImageDownloadPriority.low}) {
    if (url is! String || url.isEmpty || !url.startsWith("http")) {
      if (callback is PPImageDownloadResultCallback) {
        callback(
            null, PPErrorMessage(code: -1, message: "url is not right $url"));
      }
      return;
    }

    if (callback is PPImageDownloadResultCallback) {
      final observers = _downloadObservers[url] ?? [];
      observers.add(callback);
      _downloadObservers[url] = observers;
    }

    if (_downloadingQueue.contains(url)) {
      _log("this $url is downloading");
      return;
    }

    if (_downloadingQueue.length >= _maxDownloadCount) {
      if (priority == PPImageDownloadPriority.high) {
        _waitingQueue.insert(0, url);
      } else {
        _waitingQueue.add(url);
      }
      _log(
          "this $url enter waiting queue, current waiting count: ${_waitingQueue.length}");
    } else {
      _log("this $url will downloading");
      _download(url, retryCount: 1);
    }
  }

  Future _download(String url, {int retryCount: 0}) async {
    _downloadingQueue.add(url);
    try {
      final response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      _log("download [$url] successfully!");
      final uInt8List = Uint8List.fromList(response.data);
      PPImageCache.shared.storeImage(url, uInt8List);

      _handleCallback(url, uInt8List, null);

      _downloadingQueue.remove(url);
      _downloadNext();
    } catch (e) {
      // todo retry
      _downloadingQueue.remove(url);
      if (retryCount > 0) {
        _log("download error $url, will retry $retryCount");
        _download(url, retryCount: retryCount - 1);
      } else {
        _handleCallback(
            url, null, PPErrorMessage(code: -2, message: "download error $e"));
        _downloadNext();
      }
    }
  }

  _handleCallback(String url, Uint8List data, PPErrorMessage error) {
    final observers = _downloadObservers[url] ?? [];
    for (var callback in observers) {
      callback(data, error);
    }
    _downloadObservers.remove(url);
  }

  _downloadNext() {
    // check next download
    if (_waitingQueue.length > 0) {
      final next = _waitingQueue.first;
      _log(
          "waiting count: ${_waitingQueue.length}, will download next waiting queue url [$next]");
      _waitingQueue.remove(next);
      _download(next);
    }
  }

  _log(String log) {
    if (_logCallback is PPImageDownloadLogCallback) {
      _logCallback(log);
    }
  }
}
