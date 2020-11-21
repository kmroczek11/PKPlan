import 'dart:developer';
import 'dart:typed_data';
import 'dart:core';
import 'package:PKPlan/screens/custom_spannable_grid.dart';
import 'package:PKPlan/screens/lectures.dart';
import 'package:PKPlan/shared/loading.dart';
import 'package:excel/excel.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  List<List<String>> _schedule = [];
  int _start = 0;
  int _end = 8; // take elements + 1
  bool _loading = false;
  double _scheduleUpdateBoxHeight = 26.0;
  Color _scheduleUpdateBoxColor = Colors.green[800];

  @override
  void initState() {
    super.initState();
    this._getData();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  T _tryCast<T>(dynamic x, {T fallback}) {
    // tryParse from [int] `x`
    if (x is int) {
      if (T == String) {
        // tryParse to [String]
        return x.toString() as T ?? fallback;
      }
    }

    // tryParse from [null] `x`
    if (x == null) {
      if (T == String) {
        // tryParse to [String]
        return '' as T ?? fallback;
      }
    }

    try {
      return (x as T) ?? fallback;
    } on TypeError catch (e) {
      print('CastError when trying to cast $x to $T! Exception catched: $e');
      return fallback;
    }
  }

  bool _containsLectures(row) {
    for (String e in row) {
      for (Lecture lecture in Lectures.list)
        if (e.contains(lecture.name)) return true;
    }
    return false;
  }

  String _trimWhitespace(String stringToTrim) {
    bool encounteredChar = false;
    List<String> s = stringToTrim.split('');
    s = s.where(
      (e) {
        if (isWhitespace(e.runes.first)) {
          if (encounteredChar) {
            encounteredChar = false;
            return true;
          }
          return false;
        } else {
          encounteredChar = true;
          return true;
        }
      },
    ).toList();
    return s.join('');
  }

  List<String> _clearWhitespaces(List<String> row) {
    return row.map((e) => _trimWhitespace(e)).toList();
  }

  void _getData() async {
    setState(() => _loading = true);
    try {
      final ByteData data = await rootBundle.load("assets/schedule.xlsx");
      Uint8List bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      Excel excel = Excel.decodeBytes(bytes);
      Sheet sheet = excel['2020_2021'];
      RegExp regExp = RegExp(
        r'^([1-9]|0[1-9]|[12][0-9]|3[01])[-\.]([1-9]|0[1-9]|1[012])[-\.]\d{4}$',
      ); // regex for checking dates in format DD.MM.YY

      int lectureIndex = sheet.rows.indexWhere(
        (e) {
          if (e.first != null && regExp.hasMatch(e.first)) {
            DateTime now = DateTime.now();
            // DateTime now = DateTime.parse('2020-11-22');
            // check if first element in a row is a date
            DateTime date = DateTime.parse(
              e.first.split('.').reversed.join('.').replaceAll('.', '-'),
            ); // parse date in format DD.MM.YY to YY-MM-DD
            if (date.compareTo(now) == 0 || date.isAfter(now)) return true;
          }
          return false;
        },
      );

      List<dynamic> lecturesRange = sheet.rows
          .getRange(lectureIndex, lectureIndex + 10)
          .toList(); // get 7 rows + additional rows of nulls
      // print(lecturesRange);

      for (List<dynamic> row in lecturesRange) {
        List<dynamic> properRange = row
            .getRange(_start, _end)
            .toList(); // get only the range of the chosen yearbook
        List<String> casted = properRange
            .map((dynamic s) => _tryCast<String>(s, fallback: 'fallback'))
            .toList(); // cast a row from [List<dynamic>] to [List<String>]
        if (_containsLectures(casted)) {
          // check if row contains chosen lectures
          casted = _clearWhitespaces(casted); // remove extra whitespaces
          casted.removeAt(0); // remove first extra element
          casted.add(casted[1]); // move first break to the end
          // print('casted $casted');
          _schedule.add(casted);
        }
      }

      log(_schedule.toString());
    } catch (e) {
      print(e.toString());
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    double rowHeight = (MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top) /
        5;
    const String info =
        'Niestety plan zamieszczony na stronie jest w przestarzałym formacie.Aby wykonać aktualizację, pobierz i przekonwertuj plan do formatu xlsx, następnie wgraj do aplikacji.';

    return _loading
        ? Center(child: Loading())
        : SafeArea(
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                InkWell(
                  onTap: () => setState(
                    () => {
                      _scheduleUpdateBoxHeight = 110.0,
                      _scheduleUpdateBoxColor = Colors.green[400]
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedContainer(
                    // Use the properties stored in the State class.
                    width: 250.0,
                    height: _scheduleUpdateBoxHeight,
                    duration: Duration(seconds: 1),
                    curve: Curves.fastOutSlowIn,
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: _scheduleUpdateBoxColor,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Dostępna jest aktualizacja planu!',
                        ),
                        Expanded(
                          child: Text(
                            info,
                            overflow: TextOverflow.clip,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Container(
                //   width: MediaQuery.of(context).size.width,
                //   height: MediaQuery.of(context).size.height,
                //   child: CustomSpannableGrid(
                //     schedule: _schedule,
                //     rowHeight: rowHeight,
                //   ),
                // ),
              ],
            ),
          );
  }
}
