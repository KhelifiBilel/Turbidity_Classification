import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading2 extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 45, 42, 40),
      child: Center(
        child: SpinKitDoubleBounce(color: Colors.white,size: 50,),
      ),
    );
  }
}