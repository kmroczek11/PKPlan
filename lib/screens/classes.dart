import 'dart:ui';

class Class {
  final String name;
  final List<Color> colors;

  Class({this.name, this.colors});
}

class Classes {
  static List<Class> list = [
    Class(
        name: 'Systemy operacyjne',
        colors: [Color(0xffff7c80), Color(0xffe09092)]),
    Class(name: 'SO', colors: [Color(0xffff7c80), Color(0xffe09092)]),
    Class(
        name: 'J.angielski', colors: [Color(0xffeded55), Color(0xffFFFFFD)]),
    Class(
        name: 'Statystyka matematyczna',
        colors: [Color(0xffc0c0c0), Color(0xffe3e1e1)]),
    Class(
        name: 'Języki i paradygmaty programowania',
        colors: [Color(0xffccecff), Color(0xffe6f2fa)]),
    Class(name: 'JiPP', colors: [Color(0xff99ccff), Color(0xffb3d8fc)]),
    Class(
        name: 'Podstawy Elektroniki i Techniki Cyfrowej',
        colors: [Color(0xff00b0f0), Color(0xff53bee6)]),
    Class(name: 'PEiTC', colors: [Color(0xff00b0f0), Color(0xff53bee6)]),
  ];
}
