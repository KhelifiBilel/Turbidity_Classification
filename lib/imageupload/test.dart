import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay/model.dart';

mainn() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ExampleCameraOverlay(),
  );
}

class ExampleCameraOverlay extends StatefulWidget {
  const ExampleCameraOverlay({Key? key}) : super(key: key);

  @override
  _ExampleCameraOverlayState createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  OverlayFormat format = OverlayFormat.cardID1;
  File? file;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CameraDescription>?>(
        future: availableCameras(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == null) {
              return const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'No camera found',
                    style: TextStyle(color: Colors.black),
                  ));
            }
              return CameraOverlay(
                snapshot.data!.first,
                CardOverlay.byFormat(format),
                (file) => showDialog(
                      context: context,
                      barrierColor: Colors.black,
                      builder: (context) {
                        CardOverlay overlay = CardOverlay.byFormat(format);
                        return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                          
                            content: SizedBox(
                                width: double.infinity,
                                child: AspectRatio(
                                  aspectRatio: overlay.ratio!,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      fit: BoxFit.fitWidth,
                                      alignment: FractionalOffset.center,
                                      image: FileImage(File(file.path),
                                       // image: FileImage(File(""),

                                      ),
                                    )),
                                  ),
                                )));
                      },
                    ),
    info: '',
    label: '');
          } else {
            return const Align(
                alignment: Alignment.center,
                child: Text(
                  'Fetching cameras',
                  style: TextStyle(color: Colors.black),
                ));
          }
        },
      ),
    ));
  }
}
