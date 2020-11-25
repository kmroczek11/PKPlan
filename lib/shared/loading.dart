import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return SpinKitFoldingCube(
      color: Colors.blue,
      size: 100.0,
      controller: AnimationController(
          vsync: this, duration: const Duration(milliseconds: 2)),
    );
  }
}
