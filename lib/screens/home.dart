import 'dart:developer';
import 'dart:typed_data';
import 'dart:core';
import 'package:PKPlan/screens/custom_spannable_grid.dart';
import 'package:PKPlan/screens/lectures.dart';
import 'package:PKPlan/shared/loading.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
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
  double _scheduleUpdateBoxHeight = 26.0;
  Color _scheduleUpdateBoxColor = Colors.green[800];
  Sheet _sheet;
  RegExp _dateReg = RegExp(
    r'^([1-9]|0[1-9]|[12][0-9]|3[01])[-\.]([1-9]|0[1-9]|1[012])[-\.]\d{4}$',
  ); // regex for checking dates in format dd.MM.yyyy
  DateTime _now = DateTime.now();
  List<String> _dates = [];
  String _selectedDate;
  Future _loadSchedule;

  @override
  void initState() {
    super.initState();
    _loadSchedule = _setupData();
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

  bool _searchedDate(e) {
    if (e.first != null && _dateReg.hasMatch(e.first)) {
      // check if first element in a row is a date
      DateTime date = DateTime.parse(
        e.first.split('.').reversed.join('.').replaceAll('.', '-'),
      ); // parse date in format dd.MM.yyyy to yyyy-MM-dd
      if (date.compareTo(_now) == 0 || date.isAfter(_now)) return true;
    }
    return false;
  }

  void _getData() {
    try {
      setState(() => _schedule = []);

      int lectureIndex = _sheet.rows.indexWhere(
        (e) => _searchedDate(e),
      );

      List<dynamic> lecturesRange = _sheet.rows
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
      // log(_schedule.toString());
    } catch (e) {
      e.toString();
    }
  }

  Future _setupData() async {
    // load Excel file and create schedule
    try {
      final ByteData data = await rootBundle.load('assets/schedule.xlsx');
      Uint8List bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      Excel excel = Excel.decodeBytes(bytes);
      _sheet = excel['2020_2021'];
      List<List<dynamic>> dateRows = _sheet.rows
          .where((e) => e.first != null && _dateReg.hasMatch(e.first))
          .toList();
      dateRows.forEach((e) => _dates.add(e.first));

      setState(
        () => _selectedDate = _sheet.rows.firstWhere(
          (e) => _searchedDate(e),
        )[0],
      );

      _getData();

      return true;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    double rowHeight = (MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top) /
        5;
    const String info =
        'Niestety plan zamieszczony na stronie jest w przestarzałym formacie. Aby wykonać aktualizację, pobierz i przekonwertuj plan do formatu xlsx, następnie wgraj do aplikacji.';

    return SafeArea(
      child: Stack(
        children: <Widget>[
          FutureBuilder(
            future: _loadSchedule,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData)
                return Provider.value(
                  value: _schedule,
                  child: CustomSpannableGrid(
                    rowHeight: rowHeight,
                  ),
                );
              else
                return Center(child: Loading());
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: DropdownButton(
                    dropdownColor: Colors.black,
                    value: _selectedDate,
                    icon: Icon(
                      FontAwesomeIcons.arrowDown,
                      color: Colors.white,
                    ),
                    iconSize: 20,
                    elevation: 10,
                    style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 15.0,
                      color: Colors.white,
                    ),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String value) {
                      setState(
                        () => {
                          _selectedDate = value,
                          _now = DateTime.parse(
                            value
                                .split('.')
                                .reversed
                                .join('.')
                                .replaceAll('.', '-'),
                          ),
                        },
                      );
                      _getData();
                    },
                    items: _dates
                        .map(
                          (date) => DropdownMenuItem(
                            value: date,
                            child: Text(date),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Visibility(
                  visible: false,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
