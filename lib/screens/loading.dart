import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 182, 212, 246),
      child: Center(
        child: SpinKitFoldingCube(color: Colors.white,size: 50,),
      ),
    );
  }
  
}