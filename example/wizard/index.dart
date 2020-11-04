library test;

//import 'dart:async';
//import 'dart:html';
import 'package:centryl/base.dart';
import 'package:centryl/app.dart' as app;
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as cl_gui;
import 'package:centryl/action.dart' as cl_action;

import '../base/base.dart';

void main() {
  init();
  wiz1();
}

void wiz1() {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  // Create Form 1;
  final f1 = new cl_gui.FormElement()
    ..addRow('Test', [new cl_form.Input()])
    ..addRow('Test', [new cl_form.Input()])
    ..addRow('Test', [new cl_form.Input()])
    ..addRow('Test', [new cl_form.Input()]);

  // Create Form 2;
  final f2 = new cl_gui.FormElement()
    ..addRow('Test 2', [new cl_form.Input()])
    ..addRow('Test 2', [new cl_form.Input()])
    ..addRow('Test 2', [new cl_form.Input()])
    ..addRow('Test 2', [new cl_form.Input()]);

  // Create Wizard
  final wiz = new cl_gui.Wizard();

  // Create Steps
  final st = wiz.createStep('First step');
  final st2 = wiz.createStep('Important')..disable();
  wiz.createStep('Finish').disable();

  // Append Forms;
  st.contentDom.append(f1);
  st2.contentDom.append(f2);

  st
    ..enable()
    ..current()
    ..validate = () {
      print(f1.getValue());
      return true;
    };

  wiz.onChangeStep.listen((element) {

  });

  content..append(wiz)
   ..append(new cl_action.Button()..setTitle('Next')..addAction((e) async {
    final n = await wiz.next();
    if(n != null) {
      print(n.isLast());
    }
  }));
}