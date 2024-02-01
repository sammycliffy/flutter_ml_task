import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/widget/camera_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  runApp(MyApp(camera: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> camera;
  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(),
      home: CameraScreen(cameras: camera),
    );
  }
}
