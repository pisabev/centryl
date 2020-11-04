library application;

//import 'dart:html';
//import 'package:centryl/base.dart' as cl;
import 'package:centryl/app.dart' as app;
import 'package:centryl/chart.dart' as chart;

import '../common/base.dart';

void main() {
    init();
    //testChart();
    testChart1();
    //testCircle();
  //testBarSmall();
}

void testChart1() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Charts')..render(600, 600);

  new chart.Chart(w.getContent())
    ..addData([
      ['Иван Иванов', 23141],
      ['Димитър Димитров', 10000],
      ['Петър Събев', 31314],
      ['Христо Балабанов', 1333],
      ['Александър Александров', 200]], 'Група 1')
    ..initGraph()
    ..renderGrid()
    ..renderGraph();
}

void testChart() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Charts')..render(600, 600);

  new chart.Bar(w.getContent())
    ..setData([
    ['Иван Иванов', 23141],
    ['Димитър Димитров', 10000],
    ['Петър Събев', 31314],
    ['Христо Балабанов', 1333],
    ['Александър Александров', 200]])
    ..initGraph()
    ..renderGrid()
    ..renderGraph();
}

void testCircle() {
  final w = new app.Win(ap.desktop)
   ..setTitle('Charts')..render(350, 350);

  new chart.Circle(w.getContent())
   ..setData(75)..draw();
}

void testBarSmall() {
  final w = new app.Win(ap.desktop)
   ..setTitle('Charts')..render(350, 350);

  w.getContent()
    ..setStyle({'padding': '50px'})
    ..append(new chart.BarSmall(100)..setPercents(20));
}