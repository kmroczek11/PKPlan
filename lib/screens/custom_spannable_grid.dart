import 'dart:developer';

import 'package:PKPlan/screens/lectures.dart';
import 'package:flutter/material.dart';
import 'package:spannable_grid/spannable_grid.dart';

class CustomSpannableGrid extends StatefulWidget {
  CustomSpannableGrid({this.schedule, this.rowHeight, Key key})
      : super(key: key);

  final List<List<String>> schedule;
  final double rowHeight;

  @override
  _CustomSpannableGridState createState() => _CustomSpannableGridState();
}

class Cell {
  final String name;
  final int columnIndex;
  final int rowIndex;
  final int colSpan;

  Cell({this.name, this.columnIndex, this.rowIndex, this.colSpan});
}

class _CustomSpannableGridState extends State<CustomSpannableGrid> {
  List<SpannableGridCellData> _cells = List();
  List<Cell> _converted = [];

  @override
  void initState() {
    super.initState();
    _createHeader();
    _createCells();
  }

  Container _createCell(String text, List<Color> tileColors, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: tileColors,
        ),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Open Sans',
            fontSize: 15.0,
            color: textColor,
          ),
        ),
      ),
    );
  }

  void _createHeader() {
    [
      Cell(name: 'Godzina', columnIndex: 1, rowIndex: 1, colSpan: 1),
      Cell(name: '11', columnIndex: 2, rowIndex: 1, colSpan: 2),
      Cell(name: '12', columnIndex: 4, rowIndex: 1, colSpan: 2),
      Cell(name: '13', columnIndex: 6, rowIndex: 1, colSpan: 2),
    ].forEach(
      (e) {
        _cells.add(
          SpannableGridCellData(
            column: e.columnIndex,
            row: e.rowIndex,
            columnSpan: e.colSpan,
            rowSpan: 1,
            id: e,
            child:
                _createCell(e.name, [Colors.black, Colors.grey], Colors.white),
          ),
        );
      },
    );
  }

  void _createCells() {
    _convertToCells(widget.schedule);
    int keyCounter = 0;

    // _converted.forEach((e) => inspect(e));

    _converted.forEach(
      (cell) {
        List<Color> colors = [];
        Color textColor = Colors.black;

        if (cell.name == '') colors = [Colors.white, Colors.grey];

        if (cell.name.contains(':')) {
          colors = [Colors.black, Colors.grey];
          textColor = Colors.white;
        }

        for (Lecture lecture in Lectures.list)
          if (cell.name.contains(lecture.name)) {
            colors = lecture.colors;
            break;
          }

        _cells.add(
          SpannableGridCellData(
            column: cell.columnIndex,
            row: cell.rowIndex,
            columnSpan: cell.colSpan,
            rowSpan: 1,
            id: keyCounter,
            child: _createCell(cell.name, colors, textColor),
          ),
        );

        keyCounter++;
      },
    );
  }

  void _makePair(List<String> row, int startingIndex, int endingIndex,
      int columnIndex, int rowIndex) {
    List<String> pair = row.getRange(startingIndex, endingIndex + 1).toList();
    print('$pair $columnIndex $rowIndex');

    if (pair.contains('ćwiczenia')) {
      String lectureName = pair.firstWhere((e) => e.contains('ćwiczenia'));

      _converted.add(
        Cell(
          name: lectureName,
          columnIndex: columnIndex,
          rowIndex: rowIndex,
          colSpan: 2,
        ),
      );
    } else {
      _converted.add(
        Cell(
          name: pair.first,
          columnIndex: columnIndex,
          rowIndex: rowIndex,
          colSpan: 1,
        ),
      );

      _converted.add(
        Cell(
          name: pair[1],
          columnIndex: columnIndex + 1,
          rowIndex: rowIndex,
          colSpan: 1,
        ),
      );
    }

    columnIndex += 2;

    if (endingIndex <
        6) // ten warunek wyrzuca błąd nieprawidłowej wartości dla komórki
      _makePair(row, endingIndex + 1, endingIndex + 2, columnIndex, rowIndex);
  }

  void _convertToCells(List<Iterable<String>> schedule) {
    int rowIndex = 2; // start from the second row because first is a header

    schedule.forEach(
      (row) {
        String lectureName;

        lectureName = row.firstWhere(
          (e) => e.contains('wykład') || e.contains('angielski'),
          orElse: () => null,
        );

        if (lectureName == null) {
          _converted.add(
            Cell(
              name: row.first,
              columnIndex: 1,
              rowIndex: rowIndex,
              colSpan: 1,
            ),
          );

          _makePair(row, 2, 3, 2,
              rowIndex); // startingIndex i endingIndex do zmiany, dodatkowe puste komórki
        } else {
          _converted.add(
            Cell(
              name: row.first,
              columnIndex: 1,
              rowIndex: rowIndex,
              colSpan: 1,
            ),
          );

          _converted.add(
            Cell(
              name: lectureName,
              columnIndex: 2,
              rowIndex: rowIndex,
              colSpan: 6,
            ),
          );
        }

        rowIndex++;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SpannableGrid(
      rowHeight: widget.rowHeight,
      columns: 7,
      rows: 5,
      cells: _cells,
    );
  }
}
