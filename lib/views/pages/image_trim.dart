import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sample/views/components/common_button.dart';
import 'package:flutter_sample/views/components/common_scaffold.dart';
import 'package:image/image.dart' as imageLib;

class ImageTrim extends StatelessWidget {

  final Uint8List image;

  ImageTrim({ required this.image });

  final _controller = CropController();

  Widget build(BuildContext context) {
    return CommonScaffold(
      appBarText: '',
      body: Column(
        children: [
          Expanded(
            child: _Crop(
              image: image,
              aspectRatio: 1, // アスペクト比固定
              controller: _controller,
              onCropped: (image) => Navigator.pop(context, image),
            ),
          ),
          SizedBox(height: 30),
          CommonButton(
              label: '決定',
              onPressed: () {
                _controller.crop();
              },
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}

/// 以下ライブラリを一部修正して使用
/// https://github.com/chooyan-eng/crop_your_image
const dotTotalSize = 32.0; // fixed corner dot size.

typedef CornerDotBuilder = Widget Function(double size, int cornerIndex);

/// Widget for the entry point of crop_your_image.
class _Crop extends StatelessWidget {
  /// original image data
  final Uint8List image;

  /// callback when cropping completed
  final ValueChanged<Uint8List> onCropped;

  /// fixed aspect ratio of cropping area.
  /// null, by default, means no fixed aspect ratio.
  final double? aspectRatio;

  /// initial size of cropping area.
  /// Set double value less than 1.0.
  /// if initialSize is 1.0 (or null),
  /// cropping area would expand as much as possible.
  final double? initialSize;

  /// Initial [Rect] of cropping area.
  /// This [Rect] must be based on the rect of [image] data, not screen.
  ///
  /// e.g. If the original image size is 1280x1024,
  /// giving [Rect.fromLTWH(240, 212, 800, 600)] as [initialArea] would
  /// result in covering exact center of the image with 800x600 image size.
  ///
  /// If [initialArea] is given, [initialSize] is ignored.
  /// In other hand, [aspectRatio] is still enabled although initial shape of
  /// cropping area depends on [initialArea]. Once user moves cropping area
  /// with their hand, the shape of cropping area is calculated depending on [aspectRatio].
  final Rect? initialArea;

  /// flag if cropping image with circle shape.
  /// if [true], [aspectRatio] is fixed to 1.
  final bool withCircleUi;

  /// conroller for control crop actions
  final CropController? controller;

  /// Callback that is called when cropping area moved.
  final ValueChanged<Rect>? onMoved;

  /// [Color] of the mask widget which is placed over the cropping editor.
  final Color? maskColor;

  /// [Color] of the base color of the cropping editor.
  final Color baseColor;

  /// builder for corner dot widget.
  /// [CornerDotBuilder] passes [size] which indicates the size of each dots
  /// and [cornerIndex] which indicates the position of each dots like below:
  /// 0: left-top, 1: right-top, 2: left-bottom, 3: right-bottom.
  /// If default dot Widget with different color is needed, [DotControl] is available.
  final CornerDotBuilder? cornerDotBuilder;

  const _Crop({
    Key? key,
    required this.image,
    required this.onCropped,
    this.aspectRatio,
    this.initialSize,
    this.initialArea,
    this.withCircleUi = false,
    this.controller,
    this.onMoved,
    this.maskColor,
    this.baseColor = Colors.white,
    this.cornerDotBuilder,
  })  : assert((initialSize ?? 1.0) <= 1.0,
  'initialSize must be less than 1.0, or null meaning not specified.'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (c, constraints) {
        final newData = MediaQuery.of(c).copyWith(
          size: constraints.biggest,
        );
        return MediaQuery(
          data: newData,
          child: _CropEditor(
            image: image,
            onCropped: onCropped,
            aspectRatio: aspectRatio,
            initialSize: initialSize,
            initialArea: initialArea,
            withCircleUi: withCircleUi,
            controller: controller,
            onMoved: onMoved,
            maskColor: maskColor,
            baseColor: baseColor,
            cornerDotBuilder: cornerDotBuilder,
          ),
        );
      },
    );
  }
}

class _CropEditor extends StatefulWidget {
  final Uint8List image;
  final ValueChanged<Uint8List> onCropped;
  final double? aspectRatio;
  final double? initialSize;
  final Rect? initialArea;
  final bool withCircleUi;
  final CropController? controller;
  final ValueChanged<Rect>? onMoved;
  final Color? maskColor;
  final Color baseColor;
  final CornerDotBuilder? cornerDotBuilder;

  const _CropEditor({
    Key? key,
    required this.image,
    required this.onCropped,
    this.aspectRatio,
    this.initialSize,
    this.initialArea,
    this.withCircleUi = false,
    this.controller,
    this.onMoved,
    this.maskColor,
    required this.baseColor,
    this.cornerDotBuilder,
  }) : super(key: key);

  @override
  _CropEditorState createState() => _CropEditorState();
}

class _CropEditorState extends State<_CropEditor> {
  late CropController _cropController;
  late Rect _rect;
  imageLib.Image? _targetImage;
  late Rect _imageRect;

  double? _aspectRatio;
  bool _withCircleUi = false;
  bool _isFitVertically = false;

  _Calculator get calculator => _isFitVertically
      ? const _VerticalCalculator()
      : const _HorizontalCalculator();

  set rect(Rect newRect) {
    setState(() {
      _rect = newRect;
    });
    widget.onMoved?.call(_rect);
  }

  @override
  void initState() {
    _cropController = widget.controller ?? CropController();
    _cropController.delegate = CropControllerDelegate()
      ..onCrop = _crop
      ..onChangeAspectRatio = (aspectRatio) {
        _resizeWith(aspectRatio, null);
      }
      ..onChangeWithCircleUi = (withCircleUi) {
        _withCircleUi = withCircleUi;
        _resizeWith(null, null);
      }
      ..onImageChanged = _resetImage
      ..onChangeRect = (newRect) {
        rect = calculator.correct(newRect, _imageRect);
      }
      ..onChangeArea = (newArea) {
        _resizeWith(_aspectRatio, newArea);
      };

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _targetImage = _fromByteData(widget.image);
    _withCircleUi = widget.withCircleUi;
    _resetCroppingArea();
    super.didChangeDependencies();
  }

  // decode orientation awared Image.
  imageLib.Image? _fromByteData(Uint8List data) {
    final tempImage = imageLib.decodeImage(data);
    assert(tempImage != null);

    // check orientation
    switch (tempImage?.exif.data[0x0112] ?? -1) {
      case 3:
        return imageLib.copyRotate(tempImage!, 180);
      case 6:
        return imageLib.copyRotate(tempImage!, 90);
      case 8:
        return imageLib.copyRotate(tempImage!, -90);
    }
    return tempImage;
  }

  /// reset image to be cropped
  void _resetImage(Uint8List targetImage) {
    setState(() {
      _targetImage = _fromByteData(targetImage);
    });
    _resetCroppingArea();
  }

  /// reset [Rect] of cropping area with current state
  void _resetCroppingArea() {
    final screenSize = MediaQuery.of(context).size;

    final imageRatio = _targetImage!.width / _targetImage!.height;
    _isFitVertically = imageRatio < screenSize.aspectRatio;

    _imageRect = calculator.imageRect(screenSize, imageRatio);

    _resizeWith(widget.aspectRatio, widget.initialArea);
  }

  /// resize cropping area with given aspect ratio.
  void _resizeWith(double? aspectRatio, Rect? initialArea) {
    _aspectRatio = _withCircleUi ? 1 : aspectRatio;

    if (initialArea == null) {
      rect = calculator.initialCropRect(
        MediaQuery.of(context).size,
        _imageRect,
        _aspectRatio ?? 1,
        widget.initialSize ?? 1,
      );
    } else {
      final screenSizeRatio = calculator.screenSizeRatio(
        _targetImage!,
        MediaQuery.of(context).size,
      );
      rect = Rect.fromLTWH(
        _imageRect.left + initialArea.left / screenSizeRatio,
        _imageRect.top + initialArea.top / screenSizeRatio,
        initialArea.width / screenSizeRatio,
        initialArea.height / screenSizeRatio,
      );
    }
  }

  /// crop given image with given area.
  Future<void> _crop(bool withCircleShape) async {
    assert(_targetImage != null);

    final screenSizeRatio = calculator.screenSizeRatio(
      _targetImage!,
      MediaQuery.of(context).size,
    );

    // use compute() not to block UI update
    final cropResult = await compute(
      withCircleShape ? _doCropCircle : _doCrop,
      [
        _targetImage!,
        Rect.fromLTWH(
          (_rect.left - _imageRect.left) * screenSizeRatio,
          (_rect.top - _imageRect.top) * screenSizeRatio,
          _rect.width * screenSizeRatio,
          _rect.height * screenSizeRatio,
        ),
      ],
    );
    widget.onCropped(cropResult);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: widget.baseColor,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: RepaintBoundary( /** ここを修正 */
            child: Image.memory(
              widget.image,
              fit: _isFitVertically ? BoxFit.fitHeight : BoxFit.fitWidth,
            ),
          ),
        ),
        IgnorePointer(
          child: ClipPath(
            clipper: _withCircleUi
                ? _CircleCropAreaClipper(_rect)
                : _CropAreaClipper(_rect),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: widget.maskColor ?? Colors.black.withAlpha(100),
            ),
          ),
        ),
        Positioned(
          left: _rect.left,
          top: _rect.top,
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveRect(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
              );
            },
            child: Container(
              width: _rect.width,
              height: _rect.height,
              color: Colors.transparent,
            ),
          ),
        ),
        Positioned(
          left: _rect.left - (dotTotalSize / 2),
          top: _rect.top - (dotTotalSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveTopLeft(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                _aspectRatio,
              );
            },
            child: widget.cornerDotBuilder?.call(dotTotalSize, 0) ??
                const DotControl(),
          ),
        ),
        Positioned(
          left: _rect.right - (dotTotalSize / 2),
          top: _rect.top - (dotTotalSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveTopRight(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                _aspectRatio,
              );
            },
            child: widget.cornerDotBuilder?.call(dotTotalSize, 1) ??
                const DotControl(),
          ),
        ),
        Positioned(
          left: _rect.left - (dotTotalSize / 2),
          top: _rect.bottom - (dotTotalSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveBottomLeft(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                _aspectRatio,
              );
            },
            child: widget.cornerDotBuilder?.call(dotTotalSize, 2) ??
                const DotControl(),
          ),
        ),
        Positioned(
          left: _rect.right - (dotTotalSize / 2),
          top: _rect.bottom - (dotTotalSize / 2),
          child: GestureDetector(
            onPanUpdate: (details) {
              rect = calculator.moveBottomRight(
                _rect,
                details.delta.dx,
                details.delta.dy,
                _imageRect,
                _aspectRatio,
              );
            },
            child: widget.cornerDotBuilder?.call(dotTotalSize, 3) ??
                const DotControl(),
          ),
        ),
      ],
    );
  }
}

class _CropAreaClipper extends CustomClipper<Path> {
  final Rect rect;

  _CropAreaClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path()
      ..addPath(
        Path()
          ..moveTo(rect.left, rect.top)
          ..lineTo(rect.right, rect.top)
          ..lineTo(rect.right, rect.bottom)
          ..lineTo(rect.left, rect.bottom)
          ..close(),
        Offset.zero,
      )
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class _CircleCropAreaClipper extends CustomClipper<Path> {
  final Rect rect;

  _CircleCropAreaClipper(this.rect);

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: rect.center, radius: rect.width / 2))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

/// Defalt dot widget placed on corners to control cropping area.
/// This Widget automaticall fits the appropriate size.
class DotControl extends StatelessWidget {
  const DotControl({
    Key? key,
    this.color = Colors.white,
    this.padding = 8,
  }) : super(key: key);

  /// [Color] of this widget. [Colors.white] by default.
  final Color color;

  /// The size of transparent padding which exists to make dot easier to touch.
  /// Though total size of this widget cannot be changed,
  /// but visible size can be changed by setting this value.
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: dotTotalSize,
      height: dotTotalSize,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(dotTotalSize),
          child: Container(
            width: dotTotalSize - (padding * 2),
            height: dotTotalSize - (padding * 2),
            color: color,
          ),
        ),
      ),
    );
  }
}

/// process cropping image.
/// this method is supposed to be called only via compute()
Uint8List _doCrop(List<dynamic> cropData) {
  final originalImage = cropData[0] as imageLib.Image;
  final rect = cropData[1] as Rect;
  return Uint8List.fromList(
    imageLib.encodePng(
      imageLib.copyCrop(
        originalImage,
        rect.left.toInt(),
        rect.top.toInt(),
        rect.width.toInt(),
        rect.height.toInt(),
      ),
    ),
  );
}

/// process cropping image with circle shape.
/// this method is supposed to be called only via compute()
Uint8List _doCropCircle(List<dynamic> cropData) {
  final originalImage = cropData[0] as imageLib.Image;
  final rect = cropData[1] as Rect;
  return Uint8List.fromList(
    imageLib.encodePng(
      imageLib.copyCropCircle(
        originalImage,
        center:
        imageLib.Point(rect.left + rect.width / 2, rect.top + rect.height / 2),
        radius: min(rect.width, rect.height) ~/ 2,
      ),
    ),
  );
}

/// Calculation logics for various [Rect] data.
abstract class _Calculator {
  const _Calculator();

  /// calculates [Rect] of image to fit the screenSize.
  Rect imageRect(Size screenSize, double imageRatio);

  /// calculates [Rect] of initial cropping area.
  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio);

  /// calculates ratio of [targetImage] and [screenSize]
  double screenSizeRatio(imageLib.Image targetImage, Size screenSize);

  /// calculates [Rect] of the result of user moving the cropping area.
  Rect moveRect(Rect original, double deltaX, double deltaY, Rect imageRect) {
    if (original.left + deltaX < imageRect.left) {
      deltaX = (original.left - imageRect.left) * -1;
    }
    if (original.right + deltaX > imageRect.right) {
      deltaX = imageRect.right - original.right;
    }
    if (original.top + deltaY < imageRect.top) {
      deltaY = (original.top - imageRect.top) * -1;
    }
    if (original.bottom + deltaY > imageRect.bottom) {
      deltaY = imageRect.bottom - original.bottom;
    }
    return Rect.fromLTWH(
      original.left + deltaX,
      original.top + deltaY,
      original.width,
      original.height,
    );
  }

  /// calculates [Rect] of the result of user moving the top-left dot.
  Rect moveTopLeft(Rect original, double deltaX, double deltaY, Rect imageRect,
      double? aspectRatio) {
    final newLeft =
    max(imageRect.left, min(original.left + deltaX, original.right - 40));
    final newTop =
    min(max(original.top + deltaY, imageRect.top), original.bottom - 40);
    if (aspectRatio == null) {
      return Rect.fromLTRB(
        newLeft,
        newTop,
        original.right,
        original.bottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = original.right - newLeft;
        var newHeight = newWidth / aspectRatio;
        if (original.bottom - newHeight < imageRect.top) {
          newHeight = original.bottom - imageRect.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTRB(
          original.right - newWidth,
          original.bottom - newHeight,
          original.right,
          original.bottom,
        );
      } else {
        var newHeight = original.bottom - newTop;
        var newWidth = newHeight * aspectRatio;
        if (original.right - newWidth < imageRect.left) {
          newWidth = original.right - imageRect.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTRB(
          original.right - newWidth,
          original.bottom - newHeight,
          original.right,
          original.bottom,
        );
      }
    }
  }

  /// calculates [Rect] of the result of user moving the top-right dot.
  Rect moveTopRight(Rect original, double deltaX, double deltaY, Rect imageRect,
      double? aspectRatio) {
    final newTop =
    min(max(original.top + deltaY, imageRect.top), original.bottom - 40);
    final newRight =
    max(min(original.right + deltaX, imageRect.right), original.left + 40);
    if (aspectRatio == null) {
      return Rect.fromLTRB(
        original.left,
        newTop,
        newRight,
        original.bottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = newRight - original.left;
        var newHeight = newWidth / aspectRatio;
        if (original.bottom - newHeight < imageRect.top) {
          newHeight = original.bottom - imageRect.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTWH(
          original.left,
          original.bottom - newHeight,
          newWidth,
          newHeight,
        );
      } else {
        var newHeight = original.bottom - newTop;
        var newWidth = newHeight * aspectRatio;
        if (original.left + newWidth > imageRect.right) {
          newWidth = imageRect.right - original.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTRB(
          original.left,
          original.bottom - newHeight,
          original.left + newWidth,
          original.bottom,
        );
      }
    }
  }

  /// calculates [Rect] of the result of user moving the bottom-left dot.
  Rect moveBottomLeft(Rect original, double deltaX, double deltaY,
      Rect imageRect, double? aspectRatio) {
    final newLeft =
    max(imageRect.left, min(original.left + deltaX, original.right - 40));
    final newBottom =
    max(min(original.bottom + deltaY, imageRect.bottom), original.top + 40);

    if (aspectRatio == null) {
      return Rect.fromLTRB(
        newLeft,
        original.top,
        original.right,
        newBottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = original.right - newLeft;
        var newHeight = newWidth / aspectRatio;
        if (original.top + newHeight > imageRect.bottom) {
          newHeight = imageRect.bottom - original.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTRB(
          original.right - newWidth,
          original.top,
          original.right,
          original.top + newHeight,
        );
      } else {
        var newHeight = newBottom - original.top;
        var newWidth = newHeight * aspectRatio;
        if (original.right - newWidth < imageRect.left) {
          newWidth = original.right - imageRect.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTRB(
          original.right - newWidth,
          original.top,
          original.right,
          original.top + newHeight,
        );
      }
    }
  }

  /// calculates [Rect] of the result of user moving the bottom-right dot.
  Rect moveBottomRight(Rect original, double deltaX, double deltaY,
      Rect imageRect, double? aspectRatio) {
    final newRight =
    min(imageRect.right, max(original.right + deltaX, original.left + 40));
    final newBottom =
    max(min(original.bottom + deltaY, imageRect.bottom), original.top + 40);
    if (aspectRatio == null) {
      return Rect.fromLTRB(
        original.left,
        original.top,
        newRight,
        newBottom,
      );
    } else {
      if (deltaX.abs() > deltaY.abs()) {
        var newWidth = newRight - original.left;
        var newHeight = newWidth / aspectRatio;
        if (original.top + newHeight > imageRect.bottom) {
          newHeight = imageRect.bottom - original.top;
          newWidth = newHeight * aspectRatio;
        }

        return Rect.fromLTWH(
          original.left,
          original.top,
          newWidth,
          newHeight,
        );
      } else {
        var newHeight = newBottom - original.top;
        var newWidth = newHeight * aspectRatio;
        if (original.left + newWidth > imageRect.right) {
          newWidth = imageRect.right - original.left;
          newHeight = newWidth / aspectRatio;
        }
        return Rect.fromLTWH(
          original.left,
          original.top,
          newWidth,
          newHeight,
        );
      }
    }
  }

  /// correct [Rect] not to exceed [Rect] of image.
  Rect correct(Rect rect, Rect imageRect) {
    return Rect.fromLTRB(
      max(rect.left, imageRect.left),
      max(rect.top, imageRect.top),
      min(rect.right, imageRect.right),
      min(rect.bottom, imageRect.bottom),
    );
  }
}

class _HorizontalCalculator extends _Calculator {
  const _HorizontalCalculator();

  @override
  Rect imageRect(Size screenSize, double imageRatio) {
    final imageScreenHeight = screenSize.width / imageRatio;
    final top = (screenSize.height - imageScreenHeight) / 2;
    final bottom = top + imageScreenHeight;
    return Rect.fromLTWH(0, top, screenSize.width, bottom - top);
  }

  @override
  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio) {
    final imageRatio = imageRect.width / imageRect.height;
    final imageScreenHeight = screenSize.width / imageRatio;

    final initialSize = imageRatio > aspectRatio
        ? Size((imageScreenHeight * aspectRatio) * sizeRatio,
        imageScreenHeight * sizeRatio)
        : Size(screenSize.width * sizeRatio,
        (screenSize.width / aspectRatio) * sizeRatio);

    return Rect.fromLTWH(
      (screenSize.width - initialSize.width) / 2,
      (screenSize.height - initialSize.height) / 2,
      initialSize.width,
      initialSize.height,
    );
  }

  @override
  double screenSizeRatio(imageLib.Image targetImage, Size screenSize) {
    return targetImage.width / screenSize.width;
  }
}

class _VerticalCalculator extends _Calculator {
  const _VerticalCalculator();

  @override
  Rect imageRect(Size screenSize, double imageRatio) {
    final imageScreenWidth = screenSize.height * imageRatio;
    final left = (screenSize.width - imageScreenWidth) / 2;
    final right = left + imageScreenWidth;
    return Rect.fromLTWH(left, 0, right - left, screenSize.height);
  }

  @override
  Rect initialCropRect(
      Size screenSize, Rect imageRect, double aspectRatio, double sizeRatio) {
    final imageRatio = imageRect.width / imageRect.height;
    final imageScreenWidth = screenSize.height * imageRatio;

    final initialSize = imageRatio < aspectRatio
        ? Size(imageScreenWidth * sizeRatio,
        imageScreenWidth / aspectRatio * sizeRatio)
        : Size((screenSize.height * aspectRatio) * sizeRatio,
        screenSize.height * sizeRatio);

    return Rect.fromLTWH(
      (screenSize.width - initialSize.width) / 2,
      (screenSize.height - initialSize.height) / 2,
      initialSize.width,
      initialSize.height,
    );
  }

  @override
  double screenSizeRatio(imageLib.Image targetImage, Size screenSize) {
    return targetImage.height / screenSize.height;
  }
}

class CropController {
  late CropControllerDelegate _delegate;

  /// setter for [CropControllerDelegate]
  set delegate(CropControllerDelegate value) => _delegate = value;

  /// crop given image with current configuration
  void crop() => _delegate.onCrop(false);

  /// crop given image with current configuration and circle shape.
  void cropCircle() => _delegate.onCrop(true);

  /// Change image to be cropped.
  /// When image is changed, [Rect] of cropping area will be reset.
  set image(Uint8List value) => _delegate.onImageChanged(value);

  /// change fixed aspect ratio
  /// if [value] is null, cropping area can be moved without fixed aspect ratio.
  set aspectRatio(double? value) => _delegate.onChangeAspectRatio(value);

  /// change if cropping with circle shaped UI.
  /// if [value] is true, [aspectRatio] automatically fixed with 1
  set withCircleUi(bool value) => _delegate.onChangeWithCircleUi(value);

  /// change [Rect] of cropping area.
  /// the value is corrected if it indicates outside of the image.
  set rect(Rect value) => _delegate.onChangeRect(value);

  /// change [Rect] of cropping area based on [Rect] of original imgage.
  set area(Rect value) => _delegate.onChangeArea(value);
}

/// Delegate of actions from [CropController]
class CropControllerDelegate {
  /// callback that [CropController.crop] is called.
  /// the meaning of the value is if cropping a image with circle shape.
  late ValueChanged<bool> onCrop;

  /// callback that [CropController.image] is set.
  late ValueChanged<Uint8List> onImageChanged;

  /// callback that [CropController.aspectRatio] is set.
  late ValueChanged<double?> onChangeAspectRatio;

  /// callback that [CropController.withCircleUi] is changed.
  late ValueChanged<bool> onChangeWithCircleUi;

  /// callback that [CropController.rect] is changed.
  late ValueChanged<Rect> onChangeRect;

  /// callback that [CropController.area] is changed.
  late ValueChanged<Rect> onChangeArea;
}
