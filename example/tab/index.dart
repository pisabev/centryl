library test;

//import 'dart:async';
import 'dart:html';
import 'package:centryl/base.dart';
import 'package:centryl/app.dart' as app;
import 'package:centryl/forms.dart' as cl_form;
//import 'package:centryl/action.dart' as cl_action;
import 'package:centryl/gui.dart' as cl_gui;

import '../common/base.dart';

void main() {
  init();
  final w = new app.Win(ap.desktop)
    ..setTitle('Tabs')..render(700, 800);

  final tabs = new cl_gui.TabContainer();
  final t1 = tabs.createTab('First');
  final t2 = tabs.createTab('Second');
  tabs.createTab('Third');
  final t4 = tabs.createTab('Nested');

  tabs
    ..createTab('Long long title')
    ..createTab('Random title')
    ..createTab('Other')
    ..activeTab(t1);

  final form = new cl_form.Form();
  t1.append(getForm(form));
  t2.append(getForm1(form));
  t4.append(getNestedTab());

  w.getContent().append(tabs);
}

cl_gui.FormElement getForm(cl_form.Form f) =>
  new cl_gui.FormElement(f)
    ..addRow('Row1', [new cl_form.Input()
      ..setName('key1')])
    ..addRow('Row2', [new cl_form.Input()..setName('key2')])
    ..addRow('Row2', [new cl_form.Input()..setName('key3'),
      new CLElement(new SpanElement())..setText('some'),
      new cl_form.Input()..setName('key4')]);

cl_gui.FormElement getForm1(cl_form.Form f) => new cl_gui.FormElement(f)
  ..addRow('Row1', [new cl_form.Input()..setName('key1')])
  ..addRow('Row11', [new cl_form.Input()..setName('key1')])
  ..addRow('Row12', [new cl_form.Input()..setName('key1')])
  ..addRow('Row2', [new cl_form.Input()..setName('key2')])
  ..addRow('Row2', [new cl_form.Input()..setName('key3'),
    new CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key4')]);

cl_gui.TabContainer getNestedTab() {
  final tabs = new cl_gui.TabContainer();
  final t1 = tabs.createTab('First');
  tabs
    ..createTab('Second')
    ..createTab('Third')
    ..activeTab(t1);

  final form = new cl_form.Form();
  t1.append(getForm(form));
  return tabs;
}