part of 'pp_image.dart';

class PPImageItem {
  final uniqueKey = UniqueKey();
  String url;
  PPImageDownloadPriority priority;
  PPImageItem({@required this.url, this.priority: PPImageDownloadPriority.low});
}
