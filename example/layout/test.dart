library test.layout;

//import 'dart:async';
import 'dart:html';
import 'package:centryl/base.dart' as cl;
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as gui;
//import 'package:centryl/action.dart' as cl_action;

class ExaminationLayout extends cl.Container {
  cl.Container contTop,
      contBottom,
      contMiddle,
      contTopLeft,
      contTopRight,
      contBottomLeft,
      contBottomRight,
      contMenu,
      contScroll;

  ExaminationLayout() : super() {
    contTop = new cl.Container();
    contTopLeft = new cl.Container()
      ..auto = true
      ..setStyle({'border-right': '1px solid #9922EE'});
    contTopRight = new cl.Container();
    contTop..addCol(contTopLeft)..addCol(contTopRight);

    contMiddle = new cl.Container();

    contBottom = new cl.Container();
    contBottomLeft = new cl.Container()
      ..auto = true
      ..setStyle({'border-right': '1px solid #9922EE'});
    contBottomRight = new cl.Container();
    contBottom..addCol(contBottomLeft)..addCol(contBottomRight);

    contMenu = new cl.Container();

    //var contScrWrapper = new cl.Container();
    contScroll = new cl.Container()
      ..addRow(contTop)
      ..addRow(contMiddle)
      ..addRow(contBottom);

    //contScrWrapper.append(contScroll, scrollable: true);

    addRow(contScroll..auto = true);
    addRow(contMenu);
  }
}

class LayoutContainer extends cl.Container {
  cl.Container contMenu;
  cl.Container contBottom;

  LayoutContainer() : super() {
    contMenu = new cl.Container();
    contBottom = new cl.Container()..auto = true;

    addRow(contMenu);
    addRow(contBottom);
  }
}

gui.FormElement getForm(cl_form.Form<cl_form.Data> f) =>
 new gui.FormElement(f)
  ..addRow('Row1', [
    new cl_form.Input()
      ..setName('key11')
      ..addClass('max')])
  ..addRow('Row2', [new cl_form.Input()..setName('key22')])
  ..addRow('Row2', [
    new cl_form.Input()..setName('key33'),
    new cl.CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key44')])
  ..addRow('Row3', [
    new cl_form.Input()..setName('key33'),
    new cl.CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key44')])
  ..addRow('Row2', [
    new cl_form.Input()..setName('key33'),
    new cl.CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key44')]);
