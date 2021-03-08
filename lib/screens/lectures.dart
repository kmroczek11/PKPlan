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
        colors: [Color(0xffe0efd4), Color(0xffe9efe9)]),
    Lecture(name: 'AM', colors: [Color(0xffe0efd4), Color(0xffe9efe9)]),
    // Lecture(
    //     name: 'Algebra z geometrią',
    //     colors: [Color(0xff00FF00), Color(0xffd7f5d7)]),
    // Lecture(
    //     name: 'Wstęp do programowania',
    //     colors: [Color(0xffFFC000), Color(0xfff5ecd3)]),
    // Lecture(name: 'WDP', colors: [Color(0xffFFC000), Color(0xfff5ecd3)]),
    // Lecture(
    //     name: 'Podstawy fizyki',
    //     colors: [Color(0xff99CCFF), Color(0xffdfe9f2)]),
    Lecture(
        name: 'J.angielski', colors: [Color(0xffeded55), Color(0xffFFFFFD)]),
    // Lecture(
    //     name: 'Zagadnienia społeczne i zawodowe informatyki',
    //     colors: [Color(0xff800080), Color(0xffebcceb)]),

    Lecture(
        name: 'Algorytmy i Struktury Danych',
        colors: [Color(0xff72bf44), Color(0xff90bf80)]),
    Lecture(name: 'ASD', colors: [Color(0xff72bf44), Color(0xff90bf80)]),
    Lecture(
        name: 'Języki i Paradygmaty Progamowania',
        colors: [Color(0xfff7ba6e), Color(0xfff9cc9e)]),
    Lecture(name: 'JiPP', colors: [Color(0xfff7ba6e), Color(0xfff9cc9e)]),
    Lecture(
        name: 'Matematyka Dyskretna',
        colors: [Color(0xffc7a0cb), Color(0xffe9a9cb)]),
    Lecture(name: 'MD', colors: [Color(0xffc7a0cb), Color(0xffe9a9cb)]),
  ];
}
