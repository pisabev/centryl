library test.cl.input;

//import 'dart:async';
//import 'dart:html';
//import 'package:centryl/base.dart';
import 'package:centryl/app.dart' as app;
//import 'package:centryl/forms.dart' as cl_form;
//import 'package:centryl/action.dart' as cl_action;
//import 'package:centryl/gui.dart' as gui;

import '../base/base.dart';
import 'test.dart';

void main() {
  init();
  new app.Win(ap.desktop)
   ..setTitle('Inputs')..render(950, 850)
   ..getContent().append(run(ap), scrollable: true);
}