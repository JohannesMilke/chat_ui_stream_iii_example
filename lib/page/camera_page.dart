import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:camerawesome/models/flashmodes.dart';
import 'package:camerawesome/models/orientations.dart';
import 'package:chat_ui_stream_iii_example/page/photo_preview_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgUtils;
import 'package:path_provider/path_provider.dart';

// https://github.com/Apparence-io/camera_awesome/blob/master/example/lib/main.dart

class CameraPage extends StatefulWidget {
  final bool randomPhotoName;

  CameraPage({this.randomPhotoName = true});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with TickerProviderStateMixin {
  bool _focus = false;

  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.NONE);
  ValueNotifier<double> _zoomNotifier = ValueNotifier(0);
  ValueNotifier<Size> _photoSize = ValueNotifier(null);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);

  ValueNotifier<CameraOrientations> _orientation =
      ValueNotifier(CameraOrientations.PORTRAIT_UP);

  /// use this to call a take picture
  PictureController _pictureController = new PictureController();

  AnimationController _iconsAnimationController;

  Timer _previewDismissTimer;
  Stream<Uint8List> previewStream;

  @override
  void initState() {
    super.initState();
    _iconsAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _iconsAnimationController.dispose();

    _photoSize.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          buildFullscreenCamera(),
          _buildInterface(),
        ],
      ),
    );
  }

  Widget _buildInterface() {
    return Stack(
      children: <Widget>[
        SafeArea(
          bottom: false,
          child: TopBarWidget(
              photoSize: _photoSize,
              switchFlash: _switchFlash,
              orientation: _orientation,
              rotationController: _iconsAnimationController,
              onFlashTap: () {
                switch (_switchFlash.value) {
                  case CameraFlashes.NONE:
                    _switchFlash.value = CameraFlashes.ON;
                    break;
                  case CameraFlashes.ON:
                    _switchFlash.value = CameraFlashes.AUTO;
                    break;
                  case CameraFlashes.AUTO:
                    _switchFlash.value = CameraFlashes.ALWAYS;
                    break;
                  case CameraFlashes.ALWAYS:
                    _switchFlash.value = CameraFlashes.NONE;
                    break;
                }
                setState(() {});
              },
              onChangeSensorTap: () {
                this._focus = !_focus;
                if (_sensor.value == Sensors.FRONT) {
                  _sensor.value = Sensors.BACK;
                } else {
                  _sensor.value = Sensors.FRONT;
                }
              },
              onResolutionTap: () {},
              onFullscreenTap: () {}),
        ),
        BottomBarWidget(
          onZoomInTap: () {
            if (_zoomNotifier.value <= 0.9) {
              _zoomNotifier.value += 0.1;
            }
            setState(() {});
          },
          onZoomOutTap: () {
            if (_zoomNotifier.value >= 0.1) {
              _zoomNotifier.value -= 0.1;
            }
            setState(() {});
          },
          onCaptureModeSwitchChange: () {},
          onCaptureTap: _takePhoto,
          rotationController: _iconsAnimationController,
          orientation: _orientation,
        ),
      ],
    );
  }

  _takePhoto() async {
    final Directory extDir = await getTemporaryDirectory();
    final testDir =
        await Directory('${extDir.path}/test').create(recursive: true);
    final String filePath = widget.randomPhotoName
        ? '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg'
        : '${testDir.path}/photo_test.jpg';
    await _pictureController.takePicture(filePath);
    // lets just make our phone vibrate
    HapticFeedback.mediumImpact();

    setState(() {});

    final file = File(filePath);
    final img = imgUtils.decodeImage(file.readAsBytesSync());
    print("==> img.width : ${img.width} | img.height : ${img.height}");

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => PhotoPreviewPage(imageFile: file),
    ));
  }

  _onOrientationChange(CameraOrientations newOrientation) {
    _orientation.value = newOrientation;
    if (_previewDismissTimer != null) {
      _previewDismissTimer.cancel();
    }
  }

  _onPermissionsResult(bool granted) {
    if (!granted) {
      AlertDialog alert = AlertDialog(
        title: Text('Error'),
        content: Text(
            'It seems you doesn\'t authorized some permissions. Please check on your settings and try again.'),
        actions: [
          FlatButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    } else {
      setState(() {});
      print("granted");
    }
  }

  Widget buildFullscreenCamera() {
    return Positioned(
      top: 0,
      left: 0,
      bottom: 0,
      right: 0,
      child: Center(
        child: CameraAwesome(
          onPermissionsResult: _onPermissionsResult,
          selectDefaultSize: (availableSizes) {
            return availableSizes[0];
          },
          photoSize: _photoSize,
          sensor: _sensor,
          switchFlashMode: _switchFlash,
          zoom: _zoomNotifier,
          onOrientationChanged: _onOrientationChange,
          onCameraStarted: () {},
        ),
      ),
    );
  }
}

class OrientationUtils {
  static CameraOrientations convertRadianToOrientation(double radians) {
    CameraOrientations orientation;

    if (radians == -pi / 2) {
      orientation = CameraOrientations.LANDSCAPE_LEFT;
    } else if (radians == pi / 2) {
      orientation = CameraOrientations.LANDSCAPE_RIGHT;
    } else if (radians == 0.0) {
      orientation = CameraOrientations.PORTRAIT_UP;
    } else if (radians == pi) {
      orientation = CameraOrientations.PORTRAIT_DOWN;
    }

    return orientation;
  }

  static double convertOrientationToRadian(CameraOrientations orientation) {
    switch (orientation) {
      case CameraOrientations.LANDSCAPE_LEFT:
        return -pi / 2;
      case CameraOrientations.LANDSCAPE_RIGHT:
        return pi / 2;
      case CameraOrientations.PORTRAIT_UP:
        return 0;
      case CameraOrientations.PORTRAIT_DOWN:
        return pi;
      default:
        return 0;
    }
  }

  static bool isPortraitMode(CameraOrientations orientation) =>
      orientation == CameraOrientations.PORTRAIT_DOWN ||
      orientation == CameraOrientations.PORTRAIT_UP;
}

class BottomBarWidget extends StatelessWidget {
  final AnimationController rotationController;
  final ValueNotifier<CameraOrientations> orientation;

  final Function onZoomInTap;
  final Function onZoomOutTap;
  final Function onCaptureTap;
  final Function onCaptureModeSwitchChange;

  const BottomBarWidget({
    Key key,
    @required this.rotationController,
    @required this.orientation,
    @required this.onZoomOutTap,
    @required this.onZoomInTap,
    @required this.onCaptureTap,
    @required this.onCaptureModeSwitchChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            Container(color: Colors.black12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    OptionButton(
                      icon: Icons.zoom_out,
                      rotationController: rotationController,
                      orientation: orientation,
                      onTapCallback: () => onZoomOutTap?.call(),
                    ),
                    CameraButton(onTap: () => onCaptureTap?.call()),
                    OptionButton(
                      icon: Icons.zoom_in,
                      rotationController: rotationController,
                      orientation: orientation,
                      onTapCallback: () => onZoomInTap?.call(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class OptionButton extends StatefulWidget {
  final IconData icon;
  final Function onTapCallback;
  final AnimationController rotationController;
  final ValueNotifier<CameraOrientations> orientation;
  final bool isEnabled;

  const OptionButton({
    Key key,
    this.icon,
    this.onTapCallback,
    this.rotationController,
    this.orientation,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  _OptionButtonState createState() => _OptionButtonState();
}

class _OptionButtonState extends State<OptionButton>
    with SingleTickerProviderStateMixin {
  double _angle = 0.0;
  CameraOrientations _oldOrientation = CameraOrientations.PORTRAIT_UP;

  @override
  void initState() {
    super.initState();

    Tween(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.ease))
        .animate(widget.rotationController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _oldOrientation =
                  OrientationUtils.convertRadianToOrientation(_angle);
            }
          });

    widget.orientation.addListener(() {
      _angle =
          OrientationUtils.convertOrientationToRadian(widget.orientation.value);

      if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
        widget.rotationController.reverse();
      } else if (_oldOrientation == CameraOrientations.LANDSCAPE_LEFT ||
          _oldOrientation == CameraOrientations.LANDSCAPE_RIGHT) {
        widget.rotationController.reset();

        if ((widget.orientation.value == CameraOrientations.LANDSCAPE_LEFT ||
            widget.orientation.value == CameraOrientations.LANDSCAPE_RIGHT)) {
          widget.rotationController.forward();
        } else if ((widget.orientation.value ==
            CameraOrientations.PORTRAIT_DOWN)) {
          if (_oldOrientation == CameraOrientations.LANDSCAPE_RIGHT) {
            widget.rotationController.forward(from: 0.5);
          } else {
            widget.rotationController.reverse(from: 0.5);
          }
        }
      } else if (widget.orientation.value == CameraOrientations.PORTRAIT_DOWN) {
        widget.rotationController.reverse(from: 0.5);
      } else {
        widget.rotationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.rotationController,
      builder: (context, child) {
        double newAngle;

        if (_oldOrientation == CameraOrientations.LANDSCAPE_LEFT) {
          if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
            newAngle = -widget.rotationController.value;
          }
        }

        if (_oldOrientation == CameraOrientations.LANDSCAPE_RIGHT) {
          if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
            newAngle = widget.rotationController.value;
          }
        }

        if (_oldOrientation == CameraOrientations.PORTRAIT_DOWN) {
          if (widget.orientation.value == CameraOrientations.PORTRAIT_UP) {
            newAngle = widget.rotationController.value * -pi;
          }
        }

        return IgnorePointer(
          ignoring: !widget.isEnabled,
          child: Opacity(
            opacity: widget.isEnabled ? 1.0 : 0.3,
            child: Transform.rotate(
              angle: newAngle ?? widget.rotationController.value * _angle,
              child: ClipOval(
                child: Material(
                  color: Color(0xFF4F6AFF),
                  child: InkWell(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        widget.icon,
                        color: Colors.white,
                        size: 24.0,
                      ),
                    ),
                    onTap: () {
                      if (widget.onTapCallback != null) {
                        // Trigger short vibration
                        HapticFeedback.selectionClick();

                        widget.onTapCallback();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TopBarWidget extends StatelessWidget {
  final ValueNotifier<Size> photoSize;
  final AnimationController rotationController;
  final ValueNotifier<CameraOrientations> orientation;

  final ValueNotifier<CameraFlashes> switchFlash;
  final Function onFullscreenTap;
  final Function onResolutionTap;
  final Function onChangeSensorTap;
  final Function onFlashTap;

  const TopBarWidget({
    Key key,
    @required this.photoSize,
    @required this.orientation,
    @required this.rotationController,
    @required this.switchFlash,
    @required this.onFullscreenTap,
    @required this.onFlashTap,
    @required this.onChangeSensorTap,
    @required this.onResolutionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IgnorePointer(
                        ignoring: false,
                        child: Opacity(
                          opacity: 1.0,
                          child: ValueListenableBuilder(
                            valueListenable: photoSize,
                            builder: (context, value, child) => FlatButton(
                              key: ValueKey("resolutionButton"),
                              onPressed: () {
                                HapticFeedback.selectionClick();

                                onResolutionTap?.call();
                              },
                              child: Text(
                                '${value?.width?.toInt()} / ${value?.height?.toInt()}',
                                key: ValueKey("resolutionTxt"),
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                OptionButton(
                  icon: Icons.switch_camera,
                  rotationController: rotationController,
                  orientation: orientation,
                  onTapCallback: () => onChangeSensorTap?.call(),
                ),
                SizedBox(width: 20.0),
                OptionButton(
                  rotationController: rotationController,
                  icon: _getFlashIcon(),
                  orientation: orientation,
                  onTapCallback: () => onFlashTap?.call(),
                ),
              ],
            ),
            SizedBox(height: 20.0),
          ],
        ),
      );

  IconData _getFlashIcon() {
    switch (switchFlash.value) {
      case CameraFlashes.NONE:
        return Icons.flash_off;
      case CameraFlashes.ON:
        return Icons.flash_on;
      case CameraFlashes.AUTO:
        return Icons.flash_auto;
      case CameraFlashes.ALWAYS:
        return Icons.highlight;
      default:
        return Icons.flash_off;
    }
  }
}

class CameraButton extends StatefulWidget {
  final Function onTap;

  const CameraButton({
    @required this.onTap,
  });

  @override
  _CameraButtonState createState() => _CameraButtonState();
}

class _CameraButtonState extends State<CameraButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  double _scale;
  Duration _duration = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _animationController.value;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Container(
        key: ValueKey('cameraButton' + 'Photo'),
        height: 80,
        width: 80,
        child: Transform.scale(
          scale: _scale,
          child: CustomPaint(
            painter: CameraButtonPainter(),
          ),
        ),
      ),
    );
  }

  _onTapDown(TapDownDetails details) => _animationController.forward();

  _onTapUp(TapUpDetails details) {
    Future.delayed(_duration, () {
      _animationController.reverse();
    });

    this.widget.onTap?.call();
  }

  _onTapCancel() => _animationController.reverse();
}

class CameraButtonPainter extends CustomPainter {
  final bool isRecording;

  CameraButtonPainter({
    this.isRecording = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var bgPainter = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    var radius = size.width / 2;
    var center = Offset(size.width / 2, size.height / 2);
    bgPainter.color = Colors.white.withOpacity(.5);
    canvas.drawCircle(center, radius, bgPainter);

    bgPainter.color = Colors.white;
    canvas.drawCircle(center, radius - 8, bgPainter);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
