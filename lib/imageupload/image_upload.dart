import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay/model.dart';
import 'package:image/image.dart';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as IMG;
import '../screens/loading.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageUpload extends StatefulWidget {
  final String? userId;
  const ImageUpload({Key? key, this.userId}) : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {

   Future cropSquare(String srcFilePath, String destFilePath,int value) async {
    var bytes = await File(srcFilePath).readAsBytes();
    IMG.Image? src = IMG.decodeImage(bytes);

    var cropSize = min(src!.width-50, src.height-50);
    int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    IMG.Image destImage =
      IMG.copyCrop(src, offsetX, offsetY, cropSize-60, cropSize-60);

    
    destImage = IMG.flipVertical(destImage);
    

    var jpg = IMG.encodeJpg(destImage);
    Future<File> f= File(destFilePath).writeAsBytes(jpg);
    uploadImage(f, value);
  }
  // initializing some value
  static File? _image;
  File? _imagee;
  final imagePicker = ImagePicker();
  String? downloadURL;
  String? value;
  bool loading = false;

  // uploading the image to firebase cloudstore
  Future uploadImage(var _image, int value) async {
    //final imgId = DateTime.now().millisecondsSinceEpoch.toString();
    String turb_class = '';
    String subclass = '';

    //Organisation des classes de turbidité
    if (value < 200) {
      turb_class = "Low_Turbidity";
      if (value < 50) {
        subclass = '1st_subclass';
      } else if (value < 100) {
        subclass = '2nd_subclass';
      } else if (value < 150) {
        subclass = '3rd_subclass';
      } else if (value < 200) {
        subclass = '4th_subclass';
      }
    } else if (value < 600) {
      turb_class = "Medium_Turbidity";
      if (value < 250) {
        subclass = '1st_subclass';
      } else if (value < 300) {
        subclass = '2nd_subclass';
      } else if (value < 350) {
        subclass = '3rd_subclass';
      } else if (value < 300) {
        subclass = '4th_subclass';
      } else if (value < 450) {
        subclass = '5th_subclass';
      } else if (value < 500) {
        subclass = '6th_subclass';
      } else if (value < 550) {
        subclass = '7th_subclass';
      } else if (value < 600) {
        subclass = '8th_subclass';
      }
    } else if (value < 1000) {
      turb_class = "High_Turbidity";
      if (value < 650) {
        subclass = '1st_subclass';
      } else if (value < 700) {
        subclass = '2nd_subclass';
      } else if (value < 750) {
        subclass = '3rd_subclass';
      } else if (value < 800) {
        subclass = '4th_subclass';
      } else if (value < 850) {
        subclass = '5th_subclass';
      } else if (value < 900) {
        subclass = '6th_subclass';
      } else if (value < 950) {
        subclass = '7th_subclass';
      } else if (value < 1000) {
        subclass = '8th_subclass';
      }
    }

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference reference = FirebaseStorage.instance
        .ref()
        //.child('${widget.userId}/images')
        .child('images')
        .child(turb_class)
        .child(subclass)
        .child("post_$value");

    await reference.putFile(await _image!);
    downloadURL = await reference.getDownloadURL();

    // cloud firestore
    setState(() => loading = false);
    await firebaseFirestore
        .collection("users")
        .doc(widget.userId)
        .collection("images")
        .add({'downloadURL': downloadURL, 'value': value}).whenComplete(
            () => showSnackBar("Image Uploaded", Duration(seconds: 4)));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController turbidity = new TextEditingController();
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Upload Image "),
            ),
            body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                          height: 430,
                          width: double.infinity,
                          child: Column(children: [
                            const Text("Upload Image"),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SizedBox(
                                        width: 100,),
                                      // the image that we wanted to upload
                                      Expanded(
                                          child: _image == null
                                              ? const Center(
                                                  child:Text("No image selected"))
                                              // : Image.file(_image!)),
                                              : Container(
                                                        width: 260,
                                                         height: 200,
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border.all(
                                                                    color: Colors.white),
                                                                    borderRadius: BorderRadius.circular(4),
                                                                image:
                                                                    DecorationImage(fit: BoxFit.cover,
                                                                                   alignment: FractionalOffset.center,
                                                                                    image: FileImage(File(_image!.path),),
                                                                ))),
                                                  ),
                                      ElevatedButton(
                                          onPressed: () {
                                            
                                            setState(() {
                                             mainn(context);  });
                                            // picking();
                                          },
                                          child: const Text("Select Image")),
                                      ElevatedButton(
                                          onPressed: () {
                                            if (_image != null &&
                                                turbidity.text != "") {
                                              int value =
                                                  int.parse(turbidity.text);
                                              setState(() {
                                                loading = true;
                                              });
                                              cropSquare(_image!.path ,_image!.path, value);
                                            //  _image=File('assets/a.jpg');
                                            //  uploadImage(_imagee, value);
                                            } else if (_image == null &&
                                                turbidity.text == "") {
                                              loading = false;
                                              showSnackBar(
                                                  "Select Image and enter the turbidity value",
                                                  Duration(milliseconds: 1000));
                                            } else if (turbidity.text == "") {
                                              loading = false;
                                              showSnackBar(
                                                  "Enter the turbidity value ",
                                                  Duration(milliseconds: 1000));
                                            } else if (_image == null) {
                                              loading = false;
                                              showSnackBar(
                                                  "Select Image first ",
                                                  Duration(milliseconds: 1000));
                                            }
                                          },
                                          child: const Text("Upload Image")),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 16),
                                        child: TextFormField(
                                          controller: turbidity,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter.digitsOnly
                                          ],
                                          decoration: const InputDecoration(
                                            border: UnderlineInputBorder(),
                                            labelText: 'Enter the turbidity value (ntu)',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ])))),
            ),
          );
  }

  // show snack bar

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

mainn(context) {
  WidgetsFlutterBinding.ensureInitialized();
  /*runApp(
    const ExampleCameraOverlay(),
  );*/

  Navigator.push(
      context, MaterialPageRoute(builder: (context) => ExampleCameraOverlay()));
}

class ExampleCameraOverlay extends StatefulWidget {
  const ExampleCameraOverlay({Key? key}) : super(key: key);

  @override
  _ExampleCameraOverlayState createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  OverlayFormat format = OverlayFormat.cardID1;
  static File file = File('');
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
                     //   CardOverlay overlay = CardOverlay.byFormat(format);
                        return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            backgroundColor: Colors.black,
                            title: const Text('Confirm the image',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center),
                            actions: [
                              OutlinedButton(
                                  // onPressed: () => Navigator.of(context).pop(),
                                  onPressed: () => setState(()  {
                                        //  _image = File(_ExampleCameraOverlayState.file.path);

                                        _ImageUploadState._image =File(file.path);
                                        setState(() {
                                          _ImageUploadState._image =
                                              File(file.path);
                                        });
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) => ImageUpload( )));
                                      }),
                                  child: const Icon(Icons.check))
                            ],
                            content: SizedBox(
                                child: AspectRatio(
                                  aspectRatio: 1.58,
                                  //aspectRatio: overlay.ratio!,

                                  child: Container(width: 165,
                                                 //  height: 100,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      fit: BoxFit.cover,
                                      alignment: FractionalOffset.center,
                                      image: FileImage(
                                        File(file.path),
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
