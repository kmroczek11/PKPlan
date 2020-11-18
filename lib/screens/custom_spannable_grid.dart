import 'package:PKPlan/screens/lectures.dart';
import 'package:flutter/material.dart';
import 'package:spannable_grid/spannable_grid.dart';

class CustomSpannableGrid extends StatefulWidget {
  CustomSpannableGrid({this.schedule, this.cellHeight, Key key})
      : super(key: key);

  final List<Iterable<String>> schedule;
  final double cellHeight;

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

  @override
  void initState() {
    super.initState();
    // _createCells();
    _createHeader();
  }

  Container _createCell(text, tileColors, textColor) {
    return Container(
      height: widget.cellHeight,
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
            child: Container(color: Colors.red, child: Text(e.name)),
          ),
        );
      },
    );
  }

  void _createCells() {
    int keyCounter = 0;
    int columnIndex = 0;

    widget.schedule.forEach(
      (row) {
        int spanCounter = 0;
        int rowIndex = 0;

        row.forEach(
          (e) {
            List<Color> colors = [];
            Color textColor = Colors.black;

            if (e == '') {
              colors = [Colors.white, Colors.grey];
              spanCounter++;
              return;
            }

            for (Lecture lecture in Lectures.list)
              if (e == lecture.name) {
                colors = lecture.colors;
                spanCounter = 0;
              }

            if (e.contains(':')) {
              colors = [Colors.black, Colors.grey];
              textColor = Colors.white;
            }

            _cells.add(
              SpannableGridCellData(
                column: columnIndex,
                row: rowIndex,
                rowSpan: spanCounter,
                id: keyCounter,
                child: _createCell(e, colors, textColor),
              ),
            );

            keyCounter++;
            rowIndex = 0;
          },
        );

        columnIndex++;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SpannableGrid(
        columns: 7,
        rows: 5,
        cells: _cells,
        spacing: 2.0,
      ),
    );
  }
}
