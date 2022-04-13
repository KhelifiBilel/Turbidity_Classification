import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading2 extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 0, 160, 104),
      child: Center(
        child: SpinKitCubeGrid(color: Color.fromARGB(255, 255, 255, 255),size: 50,),
      ),
    );
  }
}