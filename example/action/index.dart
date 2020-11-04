library test;

//import 'dart:html';
//import 'package:centryl/base.dart';
import 'package:centryl/app.dart' as app;

import '../base/base.dart';
import 'test.dart';

void main() {
  init();
  new app.Win(ap.desktop)
    ..setTitle('Inputs')
    ..render(800, 800)
    ..getContent().append(run(), scrollable: true);
}