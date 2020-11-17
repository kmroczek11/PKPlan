import 'dart:developer';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<List<String>> _schedule = [];
  List<String> _lectures = [
    'Analiza matematyczna',
    'Algebra z geometrią',
    'Wstęp do programowania',
    'WDP',
    'Podstawy fizyki',
    'J.angielski',
    'Zagadnienia społeczne i zawodowe informatyki',
  ];

  @override
  void initState() {
    super.initState();
    this._getData();
  }

  bool _getLectures(row) {
    row.forEach(
      (e) {
        for (String lecture in _lectures) if (e.contains(lecture)) return true;
      },
    );
    return false;
  }

  List<String> _filterData(row) {
    return row.map(
      (e) {
        for (String lecture in _lectures)
          if (e.contains(lecture) || e.contains(':')) return false;
      },
    ).toList();
  }

  String _clearSpaces(e) {
    String cleared = '';
    e = e.trim();
    for (String w in e) {
      cleared += w + ' ';
      if (w != e[e.length]) cleared += ' ';
    }
    return cleared;
  }

  T _tryCast<T>(dynamic x, {T fallback}) {
    // tryParse from [int] `x`
    if (x is int) {
      if (T == String) {
        // tryParse to [String]
        return x.toString() as T ?? fallback;
      }
    }

    try {
      return (x as T) ?? fallback;
    } on TypeError catch (e) {
      print('CastError when trying to cast $x to $T! Exception catched: $e');
      return fallback;
    }
  }

  void _getData() async {
    try {
      final ByteData data = await rootBundle.load("assets/schedule.xlsx");
      Uint8List bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      Excel excel = Excel.decodeBytes(bytes);
      Sheet sheet = excel['2020_2021'];
      RegExp regExp = RegExp(
        r'^([1-9]|0[1-9]|[12][0-9]|3[01])[-\.]([1-9]|0[1-9]|1[012])[-\.]\d{4}$',
      );
      DateTime now = DateTime.now();
      List<dynamic> first;
      List<dynamic> second;

      for (List<dynamic> row in sheet.rows) {
        DateTime date;
        if (regExp.hasMatch(row[0].toString()))
          date = DateTime.parse(
            row[0].split('.').reversed.join('.').replaceAll('.', '-'),
          );

        if (date != null && date.isAfter(now)) {
          if (first == null) {
            first = row;
            now = date;
          } else
            second = row;
        }
        if (first != null) {
          row.removeWhere((v) => v == null);
          row = row.map((s) => _tryCast<String>(s, fallback: '')).toList();
          if (_getLectures(row)) {
            print('znaleziono wykład $row');
            // row = _filterData(row);
            // row.map((e) => _clearSpaces(e)).toList();
            _schedule.add(row);
          }
        }

        if (second != null) break;
      }
      print((_schedule));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
