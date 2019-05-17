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

  PPImage({
    this.image,
    this.fit,
    this.placeholder,
    this.fadeIn = false,
  });

  @override
  State<StatefulWidget> createState() {
    return _PPImageState();
  }
}

class _PPImageState extends State<PPImage> with SingleTickerProviderStateMixin {
  bool noCache;
  ImageProvider imageProvider;
  AnimationController animationController;
  _AnimationType animationType;

  @override
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  initState() {
    super.initState();
    setupAnimationController();
    loadImage();
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

  loadImage() async {
    final cachedImageProvider =
        await PPImageCache.shared.fetchImage(widget.image);
    if (!mounted) return;
    if (cachedImageProvider == null) {
      setState(() {
        noCache = true;
      });
      final remoteImageProvider = await widget.image.download();
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
      setState(() {
        imageProvider = remoteImageProvider;
      });
    } else {
      setState(() {
        noCache = false;
        imageProvider = cachedImageProvider;
      });
    }
  }

  Widget renderImage() {
    if (widget.image is PPNetworkImageItem) {
      return Image(
        image: imageProvider,
        fit: widget.fit,
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    if (noCache == null) return Container();
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
