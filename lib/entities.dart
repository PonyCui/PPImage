part of 'pp_image.dart';

class PPImageItem {
  String itemId;

  PPImageItem({this.itemId});

  Future<ImageProvider> download() async {
    return null;
  }
}

class PPNetworkImageItem extends PPImageItem {
  String url;

  PPNetworkImageItem({@required this.url}) : super(itemId: url);

  @override
  Future<ImageProvider> download() async {
    if (this.url == null) {
      return null;
    }
    final response = await Dio().get<List<int>>(
      this.url,
      options: Options(responseType: ResponseType.bytes),
    );
    final uInt8List = Uint8List.fromList(response.data);
    PPImageCache.shared.storeImage(this, uInt8List);
    return MemoryImage(uInt8List);
  }
}
