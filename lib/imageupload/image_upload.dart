import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_overlay/flutter_camera_overlay.dart';
import 'package:flutter_camera_overlay/model.dart'; 

import '../screens/loading.dart';
import 'test.dart';

class ImageUpload extends StatefulWidget {
  
  final String? userId;
  const ImageUpload({Key? key, this.userId}) : super(key: key);

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  // initializing some values
  File? _image;
  final imagePicker = ImagePicker();
  String? downloadURL;
  String? value;
  bool loading=false;

  // picking the image

  Future picking() async {
    final pick = await imagePicker.pickImage(source: ImageSource.camera);
 
   setState(() {
      if (pick != null) {
        _image = File(pick.path);
      } else {
        showSnackBar("No File selected", Duration(milliseconds: 1000));
      }
    });
   
  }


  // uploading the image to firebase cloudstore
  Future uploadImage(File _image,int value) async {
    //final imgId = DateTime.now().millisecondsSinceEpoch.toString();
    String turb_class='';String subclass='';

    //Organisation des classes de turbidité
    if(value<200){  turb_class="Low_Turbidity";
      if (value<50){ subclass='1st_subclass';}
      else if (value<100){ subclass='2nd_subclass';}
      else if (value<150){ subclass='3rd_subclass';}
      else if (value<200){subclass='4th_subclass';}
    }
    else if (value<600){  turb_class="Medium_Turbidity";
      if (value<250){subclass='1st_subclass';}
      else if (value<300){ subclass='2nd_subclass';}
      else if (value<350){subclass='3rd_subclass';}
      else if (value<300){subclass='4th_subclass';}
      else if (value<450){subclass='5th_subclass';}
      else if (value<500){subclass='6th_subclass';}
      else if (value<550){subclass='7th_subclass';}
      else if (value<600){subclass='8th_subclass';}
    }
    else if (value<1000){  turb_class="High_Turbidity";
      if (value<650){subclass='1st_subclass';}
      else if (value<700){ subclass='2nd_subclass';}
      else if (value<750){subclass='3rd_subclass';}
      else if (value<800){subclass='4th_subclass';}
      else if (value<850){subclass='5th_subclass';}
      else if (value<900){subclass='6th_subclass';}
      else if (value<950){subclass='7th_subclass';}
      else if (value<1000){subclass='8th_subclass';}
    }

    
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    Reference reference = FirebaseStorage.instance
        .ref()
        //.child('${widget.userId}/images')
        .child('images')
        .child(turb_class)
        .child(subclass)
        .child("post_$value");
        

    await reference.putFile(_image);
    downloadURL = await reference.getDownloadURL();

    // cloud firestore
    setState(() =>loading=false );
    await firebaseFirestore
        .collection("users")
        .doc(widget.userId)
        .collection("images")
        .add({'downloadURL': downloadURL,'value':value}).whenComplete(
            () => showSnackBar("Image Uploaded", Duration(seconds: 4)));
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController turbidity = new TextEditingController();
    return loading ? Loading(): Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image "),
      ),
      body: Center(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: SizedBox(
                    height: 500,
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
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // the image that we wanted to upload
                                Expanded(
                                    child: _image == null
                                        ? const Center(
                                            child: Text("No image selected"))
                                        : Image.file(_image!)),
                                ElevatedButton(
                                    onPressed: () {
                                       mainn();
                                    },
                                    child: const Text("Select Image")),
                                ElevatedButton(
                                    onPressed: () {
                                      
                                      if (_image != null && turbidity.text!="") {
                                        var value = int.parse(turbidity.text);
                                        setState(() =>loading=true);
                                        uploadImage(_image!,value);
                                      
                                      } else if (_image == null && turbidity.text==""){
                                        loading=false;
                                        showSnackBar("Select Image and enter the turbidity value",
                                            Duration(milliseconds: 1000));
                                      }
                                      else if (turbidity.text==""){
                                        loading=false;
                                        showSnackBar("Enter the turbidity value ",
                                            Duration(milliseconds: 1000));
                                      }
                                      else if(_image == null){
                                        loading=false; 
                                        showSnackBar("Select Image first ",
                                            Duration(milliseconds: 1000));
                                      }
                                    },
                                    child: const Text("Upload Image")),
                            
              Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
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
