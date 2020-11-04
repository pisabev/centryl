library test.cl.accordion;

//import 'dart:html';
//import 'dart:async';
//import 'package:centryl/base.dart';
//import 'package:centryl/forms.dart' as forms;
//import 'package:centryl/utils.dart' as cl;
//import 'package:centryl/forms.dart' as cl_form;
//import 'package:centryl/gui.dart' as cl_gui;
//import 'package:centryl/action.dart' as cl_action;
//import 'package:centryl/layout.dart' as layout;
//import 'package:centryl/calendar.dart' as calendar;

import 'package:centryl/app.dart' as cl_app;

import '../common/base.dart';
import 'test.dart';

void main() {
  init();
  new cl_app.Win(ap.desktop)
   ..setTitle('Inputs')
   ..render(900, 850)
    ..getContent().append(run(ap), scrollable: true);
}