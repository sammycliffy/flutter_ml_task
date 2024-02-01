import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/const/images.dart';
import 'package:flutter_assignment/edit_image.dart';
import 'package:flutter_assignment/widget/app_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription>? cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ImagePicker imagePicker = ImagePicker();
  bool _isRearCameraSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                CameraPreview(_controller),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  child: SvgPicture.asset(AppImages.cameraButton),
                  onTap: () => takePicture(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        child: SvgPicture.asset(AppImages.frame),
                        onTap: () => uploadImage(),
                      ),
                      InkWell(
                          onTap: () => setState(() {
                                _isRearCameraSelected = !_isRearCameraSelected;
                                initCamera(widget
                                    .cameras![_isRearCameraSelected ? 0 : 1]);
                              }),
                          child: SvgPicture.asset(AppImages.turnCamera))
                    ],
                  ),
                )
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  initCamera(CameraDescription camera) {
    _controller = CameraController(
      camera,
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    super.initState();

    initCamera(widget.cameras!.first);
  }

  Future takePicture() async {
    if (!_controller.value.isInitialized) {
      return null;
    }
    if (_controller.value.isTakingPicture) {
      return null;
    }
    try {
      await _controller.setFlashMode(FlashMode.off);
      XFile picture = await _controller.takePicture();

      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditImagePage(
                      image: picture,
                    )));
      }
    } on CameraException catch (e) {
      debugPrint('Error occured while taking picture: $e');
      return null;
    }
  }

  uploadImage() async {
    XFile? imageFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      if (context.mounted) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditImagePage(
                      image: imageFile,
                    )));
      }
    }

    if (imageFile == null) {
      return const Center(
        child: Text('No image selected'),
      );
    }
  }
}
