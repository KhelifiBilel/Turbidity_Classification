import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 38, 36, 35),
      child: Center(
        child: SpinKitSpinningLines(color: Colors.white,size: 50,),
      ),
    );
  }
}