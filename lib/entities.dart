part of 'pp_image.dart';

class PPImageItem {
  String url;
  PPImageDownloadPriority priority;

  PPImageItem({@required this.url, this.priority: PPImageDownloadPriority.low});
}
