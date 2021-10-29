import 'package:uuid/uuid.dart';
import 'package:PKPlan/screens/classes.dart';
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
  static int _columnsNum = 7;
  List<List<String>> _schedule = [];
  List<SpannableGridCellData> _cells = [];
  List<Cell> _converted = [];
  static List<String> _classesDuration = [
    '8:00-10:30',
    '10:45-13:15',
    '14:00-16:30',
    '16:45-19:15'
  ];
  static Uuid _uuid = Uuid();

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

  void _createLabOrEmptyPair(
      String first, String second, int colIdx, int rowIdx) {
    _converted.add(
      Cell(
        name: first,
        columnIndex: colIdx,
        rowIndex: rowIdx,
        colSpan: 1,
      ),
    );

    _converted.add(
      Cell(
        name: second,
        columnIndex: colIdx + 1,
        rowIndex: rowIdx,
        colSpan: 1,
      ),
    );
  }

  void _createExerPair(String name, int colIdx, int rowIdx) {
    _converted.add(
      Cell(
        name: name,
        columnIndex: colIdx,
        rowIndex: rowIdx,
        colSpan: 2,
      ),
    );
  }

  void _createClassCell(String name, int index) {
    _converted.add(
      Cell(
        name: name,
        columnIndex: 2,
        rowIndex: index,
        colSpan: _columnsNum - 1,
      ),
    );
  }

  void _createDurationCell(int index) {
    _converted.add(
      Cell(
        name: _classesDuration[index - 2],
        columnIndex: 1,
        rowIndex: index,
        colSpan: 1,
      ),
    );
  }

  /// Makes pairs of cells to put inside the grid
  ///
  /// [row] selected row
  ///
  /// [startingIndex] column index where to start making a pair
  ///
  /// [endingIndex] column index where to end making a pair
  ///
  /// [rowIndex] row index in the grid
  void _makeCellPairs(List<String> row, int startingIndex, int endingIndex,
      int columnIndex, int rowIndex) {
    List<String> pair = row.getRange(startingIndex, endingIndex + 1).toList();
    String exerName =
        pair.firstWhere((e) => e.contains('ćwiczenia'), orElse: () => null);

    if (exerName != null) {
      _createExerPair(exerName, columnIndex, rowIndex);
    } else {
      _createLabOrEmptyPair(pair.first, pair[1], columnIndex, rowIndex);
    }

    if (columnIndex < _columnsNum - 1)
      return _makeCellPairs(
          row, endingIndex + 1, endingIndex + 2, columnIndex + 2, rowIndex);
  }

  void _convertToCells(List<List<String>> schedule) {
    int rowIndex = 2; // start from the second row because first is a header
    // List<String> classesDuration = ['8:00\n-\n10:30', '14:00\n-\n16:30', '16:45\n-\n19:15'];
    bool addedDurationCol = false;

    schedule.forEach(
      (row) {
        String className;

        if (!addedDurationCol) {
          _createDurationCell(rowIndex);
          addedDurationCol = true;
        } else {
          className = row.firstWhere(
            (e) => e.contains('ZDALNIE') || e.contains('angielski'),
            orElse: () => null,
          );

          // znaleziono wykład
          if (className != null) {
            _createClassCell(className, rowIndex);
            addedDurationCol = false;
            rowIndex++;
            return;
          }
        }

        _makeCellPairs(row, 0, 1, 2, rowIndex);
        addedDurationCol = false;
        rowIndex++;
      },
    );
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
            fontSize: 10.0,
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
            id: _uuid.v4(),
            child:
                _createCell(e.name, [Colors.black, Colors.grey], Colors.white),
          ),
        );
      },
    );
  }

  void _createCells() {
    _convertToCells(_schedule);

    _converted.forEach(
      (cell) {
        List<Color> colors = [];
        Color textColor = Colors.black;
        RegExp exp = new RegExp(r'^[0-9]+:[0-9]+-[0-9]+:[0-9]+');

        if (exp.hasMatch(cell.name))
          // column with the classes duration
          colors = [Colors.white, Colors.grey];
        else if (cell.name == '') {
          // empty column
          colors = [Colors.black, Colors.grey];
          textColor = Colors.white;
        } else {
          // class column
          for (Class c in Classes.list)
            if (cell.name.contains(c.name)) {
              colors = c.colors;
              textColor = Colors.white;
              break;
            }
        }

        _cells.add(
          SpannableGridCellData(
            column: cell.columnIndex,
            row: cell.rowIndex,
            columnSpan: cell.colSpan,
            rowSpan: 1,
            id: _uuid.v4(),
            child: _createCell(cell.name, colors, textColor),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() => _schedule = Provider.of<List<List<String>>>(context));
    print(this._schedule);
    _createHeader();
    _createCells();

    return ScaleTransition(
      scale: _animation,
      child: SpannableGrid(
        key: ValueKey(_uuid.v4()),
        rowHeight: widget.rowHeight,
        columns: _columnsNum,
        rows: 5,
        cells: _cells,
        editingOnLongPress: false,
      ),
    );
  }
}
