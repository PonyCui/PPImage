part of 'pp_image.dart';

enum _AnimationType {
  none,
  fadeIn,
}

class PPImage extends StatefulWidget {
  final PPImageItem image;
  final BoxFit fit;
  final Widget placeholder;
  final bool fadeIn;
  final bool cancelWhenDispose;
  final String heroTag;
  final CreateRectTween heroRectTween;

  PPImage({
    this.image,
    this.fit,
    this.placeholder,
    this.fadeIn = false,
    this.cancelWhenDispose = false,
    this.heroTag,
    this.heroRectTween,
  });

  @override
  State<StatefulWidget> createState() {
    return _PPImageState();
  }
}

class _PPImageState extends State<PPImage> with SingleTickerProviderStateMixin {
  static Map<String, ImageProvider> _heroCache = {};
  static Map<String, int> _heroCacheCount = {};

  bool noCache;
  ImageProvider imageProvider;
  AnimationController animationController;
  _AnimationType animationType;

  @override
  dispose() {
    animationController.dispose();
    if (widget.cancelWhenDispose) {
      cancel();
    }
    if (widget.heroTag != null) {
      if (_heroCacheCount[widget.heroTag] != null) {
        _heroCacheCount[widget.heroTag]--;
        if (_heroCacheCount[widget.heroTag] <= 0) {
          _heroCache.remove(widget.heroTag);
        }
      }
    }
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    setupAnimationController();
    loadImage();
    if (widget.heroTag != null) {
      if (_heroCacheCount[widget.heroTag] == null) {
        _heroCacheCount[widget.heroTag] = 0;
      }
      _heroCacheCount[widget.heroTag]++;
    }
  }

  setupAnimationController() {
    animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      value: 1,
    );
    animationController.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  cancel() {
    PPImageDownloadManager.shared.cancel(widget.image.url);
  }

  loadImage() async {
    if (widget.image is! PPImageItem) {
      print("not download image");
      return;
    }
    final imageItem = widget.image;
    final cachedImageProvider =
        await PPImageCache.shared.fetchImage(imageItem.url);
    // 判断是否已经在下载，如果没在下载的，提高优先级

    if (cachedImageProvider is ImageProvider) {
      if (mounted) {
        setState(() {
          noCache = false;
          imageProvider = cachedImageProvider;
        });
        if (widget.heroTag != null) {
          _heroCache[widget.heroTag] = imageProvider;
        }
      }
      return;
    }

    if (mounted) {
      setState(() {
        noCache = true;
      });
    } else {
      noCache = true;
    }
    PPImageDownloadManager.shared.download(imageItem.url,
        priority: imageItem.priority, callback: (data, error) {
      if (data is! Uint8List) {
        // 下载失败
        return;
      }

      final remoteImageProvider = MemoryImage(data);
      if (!mounted) return;
      if (widget.fadeIn) {
        animationType = _AnimationType.fadeIn;
        animationController.value = 0.0;
        animationController
            .animateTo(
          1.0,
          duration: Duration(milliseconds: 500),
          curve: Curves.ease,
        )
            .whenCompleteOrCancel(() {
          setState(() {
            animationType = _AnimationType.none;
          });
        });
      }

      if (mounted) {
        setState(() {
          imageProvider = remoteImageProvider;
        });
        if (widget.heroTag != null) {
          _heroCache[widget.heroTag] = imageProvider;
        }
      } else {
        imageProvider = remoteImageProvider;
        if (widget.heroTag != null) {
          _heroCache[widget.heroTag] = imageProvider;
        }
      }
    });
  }

  Widget renderImage() {
    if (imageProvider == null) {
      return widget.placeholder ?? Container();
    }
    if (widget.heroTag != null) {
      return Hero(
        tag: widget.heroTag,
        createRectTween: widget.heroRectTween,
        child: Image(
          image: imageProvider,
          fit: widget.fit,
        ),
      );
    } else {
      return Image(
        image: imageProvider,
        fit: widget.fit,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.heroTag != null && _heroCache[widget.heroTag] != null) {
      return Hero(
        tag: widget.heroTag,
        createRectTween: widget.heroRectTween,
        child: Image(
          image: _heroCache[widget.heroTag],
          fit: widget.fit,
        ),
      );
    }
    if (noCache == null) {
      return Container();
    }
    if (imageProvider == null) {
      return widget.placeholder ?? Container();
    }
    if (animationType == _AnimationType.fadeIn) {
      return Stack(
        children: <Widget>[
          Positioned.fill(
            child: Opacity(
              opacity: 1.0 - animationController.value,
              child: widget.placeholder ?? Container(),
            ),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: animationController.value,
              child: renderImage(),
            ),
          ),
        ],
      );
    } else {
      return Container(
        child: renderImage(),
      );
    }
  }
}
