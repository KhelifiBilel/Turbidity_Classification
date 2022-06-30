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
import '../model/user_model.dart';
import '../screens/loading.dart';
import '../screens/home_screen.dart';

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

class ImageUpload extends StatefulWidget {
  String? userId;
 
  ImageUpload({Key? key, this.userId}) : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {

   Future cropSquare(String srcFilePath, String destFilePath,int value) async {
    var bytes = await File(srcFilePath).readAsBytes();
    IMG.Image? src = IMG.decodeImage(bytes);

    var cropSize = min(src!.width, src.height);
    int offsetX = (src.width - min(src.width, src.height)) ~/ 2;
    int offsetY = (src.height - min(src.width, src.height)) ~/ 2;

    IMG.Image destImage =
      IMG.copyCrop(src, offsetX+10, offsetY+60, cropSize-110, cropSize-160);

    var jpg = IMG.encodeJpg(destImage);
    Future<File> f= File(destFilePath).writeAsBytes(jpg);
    uploadImage(f, value);
  
  }
  // initializing some value
  static File? _image;
  String? downloadURL;
  String? value;
  bool loading = false;

  // uploading the image to firebase cloudstore
  Future uploadImage  (var _image, int value) async {

    final time = DateTime.now();
    final m=time.month;
    final d=time.day;
    final min=time.minute;
    final h=time.hour;
    final sec=time.second;
    final year=time.year;
    
    String turb_class = '';
    String subclass = '';

    //Organisation des classes de turbidité
    if (value < 150) {            // first range
      turb_class = "very_Low_Turbidity";
      if (value < 50) {
        subclass = '1st_subclass';
      } else if (value < 100) {
        subclass = '2nd_subclass';
      } else {
        subclass = '3rd_subclass';
      }
    } else if (value < 400) {      // 2nd range
      turb_class = "Low_Turbidity";
      if (value < 200) {
        subclass = '1st_subclass';
      } else if (value < 250) {
        subclass = '2nd_subclass';
      } else if (value < 300) {
        subclass = '3rd_subclass';
      } else if (value < 350) {
        subclass = '4th_subclass';
      } else  {
        subclass = '5th_subclass';
      } 
    } 
    else if (value < 700) {          // 3rd range
      turb_class = "Medium_Turbidity";
      if (value < 450) {
        subclass = '1st_subclass';
      } else if (value < 500) {
        subclass = '2nd_subclass';
      } else if (value < 550) {
        subclass = '3rd_subclass';
      } else if (value < 600) {
        subclass = '4th_subclass';
      } else if (value < 650) {
        subclass = '5th_subclass';
      } else  {
        subclass = '6th_subclass';
      } 
    }
    else {                // 4th range
      turb_class = "High_Turbidity";
      if (value < 750) {
        subclass = '1st_subclass';
      } else if (value < 800) {
        subclass = '2nd_subclass';
      } else if (value < 850) {
        subclass = '3rd_subclass';
      } else if (value < 900) {
        subclass = '4th_subclass';
      } else if (value < 950) {
        subclass = '5th_subclass';
      } else  subclass = '6th_subclass';
      }

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference reference = FirebaseStorage.instance
        .ref()
        .child('${widget.userId}/imgs')
        .child('imgs')
        .child(turb_class)
        .child(subclass)
        .child("turbidity=$value\_$d\-$m\-$year::$h\:$min\:$sec");

    await reference.putFile( await _image!);
    downloadURL = await reference.getDownloadURL();

    // cloud firestore
    await firebaseFirestore
        .collection("users1")
        .doc(widget.userId)
        .collection("imgs")
        .add({'downloadURL': downloadURL, 'value': value}).whenComplete(
            () => showSnackBar("Image Uploaded", Duration(seconds: 4)));
    setState(() => loading = false);
    
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController turbidity = new TextEditingController();
    return loading
        ? Loading()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Upload Image ",textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
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
                            const Text("Upload Image",textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              flex: 4,
                              child: Container(
                                width: 300,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.lightBlue),
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
                                                                                   
                                                                                    image: FileImage(File(_image!.path))
                                                                ))),
                                                  ),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                         context, MaterialPageRoute(builder: (context) => ExampleCameraOverlay()));
                                       
                                            
                                          },
                                          child: const Text("Select Image",textAlign: TextAlign.center,
                            style: TextStyle(
                                 fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)),
                                      ElevatedButton(
                                          onPressed: () {
                                            if (_image != null &&
                                                turbidity.text != "") {
                                              int value =int.parse(turbidity.text);

                                              setState(() {
                                                loading = true;
                                              });

                                              //CROP + UPLOADING
                                              cropSquare(_image!.path ,_image!.path, value);
                                             setState(() {
                                                _image = null;
                                              });
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
                                          child: const Text("Upload Image",textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),)),
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



class ExampleCameraOverlay extends StatefulWidget {
  const ExampleCameraOverlay({Key? key}) : super(key: key);

  @override
  _ExampleCameraOverlayState createState() => _ExampleCameraOverlayState();
}

class _ExampleCameraOverlayState extends State<ExampleCameraOverlay> {
  OverlayFormat format = OverlayFormat.cardID1;
  static File file = File('');

   UserModel loggedInUser = UserModel();
   
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
                        return AlertDialog(
                            actionsAlignment: MainAxisAlignment.center,
                            backgroundColor: Colors.black,
                            title: const Text('Confirm the image',
                                style: TextStyle(color: Colors.white),
                                textAlign: TextAlign.center),
                            actions: [
                              OutlinedButton(
                                  onPressed: () => setState(()  {
                                       //   _ImageUploadState._image = File(_ExampleCameraOverlayState.file.path);

                                     /*   setState(() {
                                          _ImageUploadState._image =
                                              File(file.path);
                                        });*/

                                         _ImageUploadState._image =File(file.path);
                                        Navigator.of(context)..pop()..pop();
                                        Navigator.of(context).pop();
                                      
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ImageUpload(
                                                   userId: loggedInUser.uid
                                          )));
                                    /* Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HomeScreen(
                                                  //  userId: loggedInUser.uid
                                                 
                                          )));*/
                                      }),
                                      
                                  child: const Icon(Icons.check))
                            ],
                            content: SizedBox(
                                child: AspectRatio(
                                  aspectRatio: 1.36,
                                  //aspectRatio: overlay.ratio!,

                                  child: Container(width: 270,
                                  
                                                   height: 0,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                      fit: BoxFit.fitWidth,
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
