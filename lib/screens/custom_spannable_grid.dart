import 'dart:developer';
import 'dart:math';
import 'package:PKPlan/screens/lectures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spannable_grid/spannable_grid.dart';

class CustomSpannableGrid extends StatefulWidget {
  CustomSpannableGrid({this.rowHeight, Key key}) : super(key: key);

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

class _CustomSpannableGridState extends State<CustomSpannableGrid>
    with TickerProviderStateMixin {
  List<List<String>> _schedule = [];
  List<SpannableGridCellData> _cells = [];
  AnimationController _controller;
  Animation<double> _animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
      value: 0.5,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceIn);
    _controller.forward();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
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
            fontFamily: 'Arial',
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
    List<Cell> converted = _convertToCells(_schedule);

    converted.forEach(
      (cell) {
        List<Color> colors = [];
        Color textColor = Colors.black;

        if (cell.name == '') colors = [Colors.white, Colors.grey];

        if (cell.name.contains('-')) {
          // column with the classes duration
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
            id: Random(),
            child: _createCell(cell.name, colors, textColor),
          ),
        );
      },
    );
  }

  List<Cell> _makePairs(List<Cell> converted, List<String> row,
      int startingIndex, int endingIndex, int columnIndex, int rowIndex) {
    List<String> pair = row.getRange(startingIndex, endingIndex + 1).toList();

    if (pair.any((e) => e.contains('ćw'))) {
      String lectureName = pair.firstWhere((e) => e.contains('ćw'));

      converted.add(
        Cell(
          name: lectureName,
          columnIndex: columnIndex,
          rowIndex: rowIndex,
          colSpan: 2,
        ),
      );
    } else {
      converted.add(
        Cell(
          name: pair.first,
          columnIndex: columnIndex,
          rowIndex: rowIndex,
          colSpan: 1,
        ),
      );

      converted.add(
        Cell(
          name: pair[1],
          columnIndex: columnIndex + 1,
          rowIndex: rowIndex,
          colSpan: 1,
        ),
      );
    }

    if (columnIndex < 6)
      return _makePairs(converted, row, endingIndex + 1, endingIndex + 2,
          columnIndex + 2, rowIndex);

    return converted;
  }

  List<Cell> _convertToCells(List<List<String>> schedule) {
    List<Cell> converted = [];
    int rowIndex = 2; // start from the second row because first is a header

    schedule.forEach(
      (row) {
        String lectureName;

        lectureName = row.firstWhere(
          (e) => e.contains('wykład') || e.contains('angielski'),
          orElse: () => null,
        );

        if (lectureName == null) {
          converted.add(
            Cell(
              name: row.first,
              columnIndex: 1,
              rowIndex: rowIndex,
              colSpan: 1,
            ),
          );

          converted = _makePairs(converted, row, 2, 3, 2, rowIndex);
        } else {
          converted.add(
            Cell(
              name: row.first,
              columnIndex: 1,
              rowIndex: rowIndex,
              colSpan: 1,
            ),
          );

          converted.add(
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
    return converted;
  }

  @override
  Widget build(BuildContext context) {
    setState(() => _schedule = Provider.of<List<List<String>>>(context));
    _createHeader();
    _createCells();

    return ScaleTransition(
      scale: _animation,
      child: SpannableGrid(
        key: ValueKey(Random()),
        rowHeight: widget.rowHeight,
        columns: 7,
        rows: 5,
        cells: _cells,
        editingOnLongPress: false,
      ),
    );
  }
}
