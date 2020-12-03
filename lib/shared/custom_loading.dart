import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomLoading extends StatefulWidget {
  CustomLoading({@required this.screen, Key key}) : super(key: key);
  final String screen;

  @override
  _CustomLoadingState createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading> {
  @override
  Widget build(BuildContext context) {
    return widget.screen == 'splash'
        ? SpinKitFoldingCube(
            color: Color(0xff2e3192),
            size: 30.0,
          )
        : SpinKitRotatingPlain(
            color: Color(0xff2e3192),
            size: 100.0,
          );
  }
}
