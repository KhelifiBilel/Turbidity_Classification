import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading1 extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 72, 74, 74),
      child: Center(
        child: SpinKitSpinningLines	(color: Color.fromARGB(255, 255, 255, 255),size: 50,),
      ),
    );
  }
}