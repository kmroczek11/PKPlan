import 'package:PKPlan/screens/home.dart';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    var future = Future.value(499);
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      future.catchError((e) {
        print(details);
      });
      // exit(1);
    };
    runApp(MyApp());
  }, (Object error, StackTrace stack) {
    print("error:\n" + error + "\nstack was:\n" + stack.toString());
    // exit(1);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xff2e3192),
      ),
      home: Home(),
      builder: (BuildContext context, Widget widget) {
        if (widget is Scaffold || widget is Navigator)
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) => Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Text(errorDetails.toString()),
                    ],
                  ),
                ),
              );
        return widget;
      },
    );
  }
}
