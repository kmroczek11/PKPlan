import 'dart:developer';
import 'dart:typed_data';
import 'dart:core';
import 'package:PKPlan/shared/loading.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quiver/strings.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class Lecture {
  final String name;
  final Color color;

  Lecture({this.name, this.color});
}

class _HomeState extends State<Home> {
  List<Iterable<String>> _schedule = [];
  List<Lecture> _lectures = [
    Lecture(name: 'Analiza matematyczna', color: Color(0xff333399)),
    Lecture(name: 'Algebra z geometrią', color: Color(0xff00FF00)),
    Lecture(name: 'Wstęp do programowania', color: Color(0xffFFC000)),
    Lecture(name: 'WDP', color: Color(0xffFFC000)),
    Lecture(name: 'Podstawy fizyki', color: Color(0xff99CCFF)),
    Lecture(name: 'J.angielski', color: Color(0xffFFFFFD)),
    Lecture(
        name: 'Zagadnienia społeczne i zawodowe informatyki',
        color: Color(0xff800080)),
  ];
  int _start = 0;
  int _end = 8; // take elements + 1
  bool _loading = false;

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
        return ' ' as T ?? fallback;
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
      for (Lecture lecture in _lectures)
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

  List<String> _clearSpaces(List<String> row) {
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
      DateTime now = DateTime.now();
      DateTime date;
      List<String> first; // first found date
      List<String> second; // second found date

      for (List<dynamic> row in sheet.rows) {
        Iterable<dynamic> range = row.getRange(_start, _end); // leave 7 cells
        List<String> casted = range
            .map((dynamic s) => _tryCast<String>(s, fallback: 'fallback'))
            .toList(); // cast a row from [List<dynamic>] to [List<String>]
        if (regExp
            .hasMatch(casted.first)) // check if first value in a row is a date
          date = DateTime.parse(
            casted.first.split('.').reversed.join('.').replaceAll('.', '-'),
          ); // parse date in format DD.MM.YY to YY/MM/DD

        if (date != null && date.isAfter(now)) {
          // check if date is found and it's after 'now' date
          if (first == null) {
            // if first date is found return it without a date
            first = casted;
            now = date; // now compare dates with a first found date
          } else // if second date is found return it without a date
            second = casted;
        }

        if (second != null)
          break; // stop searching when the second date is found

        if (first != null) {
          if (_containsLectures(casted)) {
            // check if row contains chosen lectures
            casted = _clearSpaces(casted); // remove extra whitespaces
            _schedule.add(casted.getRange(
                // remove the unnecessary first and last element);
                1,
                casted.length));
          }
        }
      }
      log(_schedule.toString());
    } catch (e) {
      print(e.toString());
    }
    setState(() => _loading = false);
  }

  Container _createCell(text, color) {
    return Container(
      color: color,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Open Sans',
          fontSize: 15.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? Center(child: Loading())
        : SafeArea(
            child: Table(
              children: <TableRow>[
                TableRow(
                  children: ['Godzina', '1', '2', '3', '4', '5', '6']
                      .map((e) => _createCell(e, Colors.white))
                      .toList(),
                ),
                for (Iterable<String> row in _schedule)
                  TableRow(
                    children: row.map(
                      (e) {
                        Color color;
                        for (Lecture lecture in _lectures)
                          if (e.contains(lecture.name)) color = lecture.color;
                        if (e == '' || e.contains(':')) color = Colors.white;
                        return _createCell(e, color);
                      },
                    ).toList(),
                  ),
              ],
            ),
          );
  }
}
