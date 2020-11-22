import 'dart:ui';

class Lecture {
  final String name;
  final List<Color> colors;

  Lecture({this.name, this.colors});
}

class Lectures {
  static List<Lecture> list = [
    Lecture(
        name: 'Analiza matematyczna',
        colors: [Color(0xff333399), Color(0xffa7a7d6)]),
    Lecture(
        name: 'Algebra z geometrią',
        colors: [Color(0xff00FF00), Color(0xffd7f5d7)]),
    Lecture(
        name: 'Wstęp do programowania',
        colors: [Color(0xffFFC000), Color(0xfff5ecd3)]),
    Lecture(name: 'WDP', colors: [Color(0xffFFC000), Color(0xfff5ecd3)]),
    Lecture(
        name: 'Podstawy fizyki',
        colors: [Color(0xff99CCFF), Color(0xffdfe9f2)]),
    Lecture(
        name: 'J.angielski', colors: [Color(0xffeded55), Color(0xffFFFFFD)]),
    Lecture(
        name: 'Zagadnienia społeczne i zawodowe informatyki',
        colors: [Color(0xff800080), Color(0xffebcceb)]),
  ];
}
