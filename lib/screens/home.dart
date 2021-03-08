import 'dart:developer';
import 'dart:typed_data';
import 'dart:core';
import 'package:PKPlan/screens/custom_spannable_grid.dart';
import 'package:PKPlan/screens/custom_splash_screen.dart';
import 'package:PKPlan/screens/lectures.dart';
import 'package:PKPlan/shared/custom_loading.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';
import 'package:string_validator/string_validator.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  List<List<String>> _schedule = [];
  List<List<String>> _rows = [];
  int _start = 0;
  int _end = 8; // take elements + 1
  int _headerRows = 6; // unnecessary header rows
  double _scheduleUpdateBoxHeight = 26.0;
  Color _scheduleUpdateBoxColor = Colors.green[800];
  Sheet _sheet;
  // RegExp _dateReg = RegExp(
  //   r'^([1-9]|0[1-9]|[12][0-9]|3[01])[-\.]([1-9]|0[1-9]|1[012])[-\.]\d{4}$',
  // ); // regex for checking dates in format dd.MM.yyyy
  DateTime _now = DateTime.now();
  List<String> _dates = [];
  String _selectedDate;
  Future _loadSchedule;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSchedule = _setupData();
  }

  void _setLandscapeOrientation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    print('$WidgetsBindingObserver metrics changed ${DateTime.now()}: '
        '${WidgetsBinding.instance.window.physicalSize.aspectRatio > 1 ? Orientation.landscape : Orientation.portrait}');
  }

  T _tryCast<T>(dynamic x, {T fallback}) {
    // tryParse from [Formula] `x`
    if (x is Formula) {
      if (T == String) {
        // tryParse to [String]
        return x.value as T ?? fallback;
      }
    }
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

  bool _containsLectures(List<String> row) {
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

  bool _isToday(DateTime date) {
    final diff = _now.difference(date).inDays;
    return diff == 0 && _now.day == date.day;
  }

  bool _searchedDate(String date) {
    if (isDate(date)) {
      DateTime d = DateTime.parse(date);
      if (_isToday(d) || d.isAfter(_now)) return true;
      return false;
    } else
      return false;
  }

  bool _isDayOff(List<List<String>> rows) {
    return rows.every(
      (row) {
        List<String> properRange = row
            .getRange(_start + 2, _end)
            .toList(); // get only the range of the chosen yearbook
        return properRange.every((e) => e == '');
      },
    );
  }

  bool _getData() {
    try {
      int lectureIndex = _rows.indexWhere(
        (row) => _searchedDate(row.first),
      );
      print(lectureIndex);

      List<List<String>> lecturesRange = _rows
          .getRange(lectureIndex, lectureIndex + 10)
          .toList(); // get 7 rows + additional rows of nulls
      // print(lecturesRange);

      if (_isDayOff(lecturesRange)) {
        Fluttertoast.showToast(
            msg:
                'Wybrany dzień jest wolny od zajęć. Wyświetlony zostanie plan na ostatni wybrany dzień.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1);
        return false;
      } else {
        setState(() => _schedule = []);

        for (List<String> row in lecturesRange) {
          List<String> properRange = row
              .getRange(_start, _end)
              .toList(); // get only the range of the chosen yearbook
          if (_containsLectures(properRange)) {
            // check if row contains chosen lectures
            properRange =
                _clearWhitespaces(properRange); // remove extra whitespaces
            properRange.removeAt(0); // remove first extra element
            properRange.add(properRange[1]); // move first break to the end
            // print('casted $casted');
            _schedule.add(properRange);
          }
          // log(_schedule.toString());
        }
      }
    } catch (e) {
      print(e.toString());
    }
    return true;
  }

  Future _setupData() async {
    // load Excel file and create schedule
    try {
      final ByteData data = await rootBundle.load('assets/schedule.xlsx');
      Uint8List bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      Excel excel = Excel.decodeBytes(bytes);
      _sheet = excel['2020_2021'];

      _rows = _sheet.rows.getRange(_headerRows, _sheet.rows.length).map(
          // cast a whole sheet
          (row) {
        if (row.first != null)
          row.first = row.first.substring(0, row.first.indexOf('T'));
        return row
            .map((dynamic s) => _tryCast<String>(s, fallback: 'fallback'))
            .toList(); // cast a row from [List<dynamic>] to [List<String>]
      }).toList();

      print(_rows);

      _rows.forEach(
        (row) => isDate(row.first) ? _dates.add(row.first) : null,
      );

      setState(
        () => _selectedDate = _dates.firstWhere(
          (date) => _searchedDate(date),
        ),
      );
      return _getData();
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

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            FutureBuilder(
              future: _loadSchedule,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  _setLandscapeOrientation();
                  return Provider.value(
                    value: _schedule,
                    child: CustomSpannableGrid(
                      rowHeight: rowHeight,
                    ),
                  );
                } else
                  return Center(
                    child: CustomLoading(screen: 'home'),
                  );
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
                    child: DropdownButtonHideUnderline(
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
                          fontFamily: 'Arial',
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                        onChanged: (String value) {
                          setState(
                            () => {
                              _now = DateTime.parse(value),
                              if (_getData()) _selectedDate = value,
                            },
                          );
                        },
                        items: _dates
                            .map(
                              (date) => DropdownMenuItem(
                                value: date,
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
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
      ),
    );
  } // build bracket
} // class bracket
