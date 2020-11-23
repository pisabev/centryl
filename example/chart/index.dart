library application;

//import 'dart:html';
//import 'package:centryl/base.dart' as cl;
import 'package:centryl/app.dart' as app;
import 'package:centryl/chart.dart' as chart;

import '../common/base.dart';

void main() {
  init();
  testChart();
  testChart1();
  testCircle();
  testBarSmall();
  testPie();
}

void testChart1() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Chart')
    ..render(600, 600);

  new chart.Chart(w.getContent())
    ..addData(new chart.DataContainer()
      ..label = 'Група 1'
      ..set = [
        new chart.DataSet('Иван Иванов', 23141),
        new chart.DataSet('Димитър Димитров', 10000),
        new chart.DataSet('Петър Събев', 31314),
        new chart.DataSet('Христо Балабанов', 1333),
        new chart.DataSet('Александър Александров', 200)
      ])
    ..initGraph()
    ..renderGrid()
    ..renderGraph();
}

void testChart() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Chart Bar')
    ..render(600, 600);

  new chart.Bar(w.getContent())
    ..setData([
      new chart.DataSet('Иван Иванов', 23141),
      new chart.DataSet('Димитър Димитров', 10000),
      new chart.DataSet('Петър Събев', 31314),
      new chart.DataSet('Христо Балабанов', 1333),
      new chart.DataSet('Александър Александров', 200)
    ])
    ..initGraph()
    ..renderGrid()
    ..renderGraph();
}

void testCircle() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Circle')
    ..render(350, 350);

  new chart.Circle(w.getContent())
    ..setData(75)
    ..draw();
}

void testBarSmall() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Bar small')
    ..render(350, 350);

  w.getContent()
    ..setStyle({'padding': '50px'})
    ..append(new chart.BarSmall(100)..setPercents(20));
}

void testPie() {
  final w = new app.Win(ap.desktop)
    ..setTitle('Pie')
    ..render(600, 600);

  new chart.Pie(w.getContent())
    ..setData([
      new chart.DataSet('Иван Иванов', 23141),
      new chart.DataSet('Димитър Димитров', 10000),
      new chart.DataSet('Петър Събев', 31314),
      new chart.DataSet('Христо Балабанов', 1333),
      new chart.DataSet('Александър Александров', 200)
    ])
    ..redraw();
}
