library test;

//import 'dart:html';
import 'package:centryl/base.dart';
import 'package:centryl/app.dart' as app;
import 'package:centryl/action.dart' as action;
import 'package:centryl/forms.dart' as form;
import 'package:centryl/layout.dart' as layout;

import '../base/base.dart';
import 'test.dart';

void main() {
  init();
  new app.Win(ap.desktop)
    ..setTitle('Layout')
    ..render(700, 800)
    ..getContent().append(testl(), scrollable: true);
}

layout.LayoutContainer1 testl() {
  final l = new layout.LayoutContainer1();
  final l0 = new Container()..setStyle({'height': '1000px'});
  final l2 = new Container()..auto = true..setStyle({'background': 'red'});
  final l3 = new Container()..auto = true..setStyle({'background': 'blue'});
//  var l4 = new Container();
  final l42 = new Container()..auto = true..setStyle({'background': 'green'});
  final l43 = new Container()..auto = true..setStyle({'background': 'yellow'});
  l0..addCol(l2)..addCol(l3);
  l3..addRow(l42)..addRow(l43);

  return l..contBottom.tab_content.append(l0);
}

layout.LayoutContainer1 test() =>
  new layout.LayoutContainer1()
    ..contMenu.setStyle({'background': 'red', 'height': '50px'})
    ..contBottom.tab_content.setStyle({'background': 'yellow'})
  ..contBottom.tab_content.append(new Container(), scrollable: true);

LayoutContainer test1() => new LayoutContainer()
  ..contBottom.append(getForm(new form.Form()), scrollable: true)
  ..contMenu.append(new action.Button()..setTitle('test'));

ExaminationLayout testm() => new ExaminationLayout()
  ..contTopRight.append(getForm(new form.Form()))
  ..contTopLeft.append(getForm(new form.Form()))
  ..contMiddle.append(getForm(new form.Form()))
  ..contBottomRight.append(getForm(new form.Form()))
  ..contBottomLeft.append(getForm(new form.Form()))
  ..contMenu.append(new action.Button()..setTitle('test'));
