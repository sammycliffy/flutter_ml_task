import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_assignment/widget/app_bar.dart';
import 'package:flutter_assignment/widget/custom_painter.dart';
import 'package:flutter_assignment/widget/custom_toast.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'const/images.dart';

class EditImagePage extends StatefulWidget {
  final XFile image;
  const EditImagePage({super.key, required this.image});

  @override
  State<EditImagePage> createState() => _EditImagePageState();
}

class _EditImagePageState extends State<EditImagePage> {
  List<Face> _faces = [];
  bool _showEyes = false;
  bool _showMouth = false;
  bool _isMultipleFacesDetected = false;
  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: appBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          _showEyes || _showMouth
              ? _buildImageWithCircles()
              : Image.file(
                  File(widget.image.path),
                  width: double.infinity,
                  height: 500,
                ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              InkWell(
                  onTap: () => Navigator.pop(context),
                  child: SvgPicture.asset(AppImages.returnIcon)),
              const SizedBox(
                width: 20,
              ),
              const Text(
                '다시찍기',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  height: 0.17,
                  letterSpacing: -0.12,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          if (!_isMultipleFacesDetected)
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        _showEyes = true;
                      }),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Center(
                          child: Text(
                            '눈',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontFamily: 'Noto Sans',
                              fontWeight: FontWeight.w400,
                              height: 0.17,
                              letterSpacing: -0.12,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    InkWell(
                      onTap: () => setState(() {
                        _showMouth = true;
                      }),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Center(
                            child: Text(
                          '입',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w400,
                            height: 0.17,
                            letterSpacing: -0.12,
                          ),
                        )),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () => _saveImage(),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: _showEyes && _showMouth
                          ? const Color(0xFF7B8FF7)
                          : const Color(0xFFD3D3D3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Center(
                        child: Text(
                      '저장하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 0.17,
                        letterSpacing: -0.12,
                      ),
                    )),
                  ),
                )
              ],
            ),
        ]),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _detectFaces();
  }

  Widget _buildImageWithCircles() {
    return FutureBuilder<ui.Image>(
      future: _loadImage(widget.image.path),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return SizedBox(
              width: double.infinity,
              height: 500,
              child: CustomPaint(
                key: key,
                painter: CirclesPainter(
                    snapshot.data!, _faces, _showEyes, _showMouth),
              ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> _detectFaces() async {
    final inputImage = InputImage.fromFilePath(widget.image.path);
    final faceDetector = GoogleMlKit.vision.faceDetector(
      FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
      ),
    );

    try {
      final faces = await faceDetector.processImage(inputImage);
      if (faces.length > 1) {
        setState(() {
          _isMultipleFacesDetected = true;
        });
        showToast("2개 이상의 얼굴이 감지되었어요!");
      }

      setState(() {
        _faces = faces;
      });
    } catch (e) {
      print('Error detecting faces: $e');
    }
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await File(path).readAsBytes();
    final image = await decodeImageFromList(Uint8List.fromList(data));

    return image;
  }

  Future<void> _saveImage() async {
    try {
      // Capture the current state of the CustomPaint
      final boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save the image to the gallery
      await ImageGallerySaver.saveImage(Uint8List.fromList(pngBytes),
          name: 'your_image_name');
    } catch (e) {
      print('Error saving image: $e');
    }
  }
}
