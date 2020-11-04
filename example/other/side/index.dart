library test;

import 'dart:html' hide Dimension;

import 'package:centryl/action.dart' as cl_action;
import 'package:centryl/app.dart' as app;
import 'package:centryl/base.dart';
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as cl_gui;

void main() {
  final ap = new app.Application(settings: new app.AppSettings())
    ..setClient(new app.Client({
      'client': {'name': 'test'}
    })
      ..addApp(new app.ClientApp()
        ..init = (ap) => new cl_action.Button()
          ..setIcon(Icon.exit_to_app)
          ..addAction((e) => window.alert('logout'))
          ..setTitle('Logout'))
      ..addApp(new app.ClientApp()
        ..init = (ap) => new cl_action.Button()
          ..setIcon(Icon.settings)
          ..addAction((e) => window.alert('settings'))
          ..setTitle('Settings')))
    ..done();
  //ap.setAbout('packages/centryl/images/icons/centryl.svg', null);

  final l = new Ap1(ap);
  l.form
      .getElement<cl_form.GridData>('grid_debit')
      .rowAdd({'account': 703, 'name': 'Monitor', 'amount': 200.0});
  l.form
      .getElement<cl_form.GridData>('grid_credit')
      .rowAdd({'account': 304, 'name': 'Suppliers', 'amount': 200.0});
}

class LayoutContainer extends Container {
  Container contMenu,
      contTop,
      contTopLeft,
      contTopRight,
      contMiddle,
      contMiddleLeft,
      contMiddleRight;

  LayoutContainer() : super() {
    contMenu = new Container();
    contTop = new Container();
    contMiddle = new Container();

    contTopLeft = new Container()..auto = true;
    contTopRight = new Container()..auto = true;

    contMiddleLeft = new Container()
      ..auto = true
      ..setStyle({'margin': '1rem'});
    contMiddleRight = new Container()
      ..auto = true
      ..setStyle({'margin': '1rem'});

    contTop..addCol(contTopLeft)..addCol(contTopRight);

    contMiddle..addCol(contMiddleLeft)..addCol(contMiddleRight);

    addRow(contTop);
    addRow(contMiddle..auto = true);
    addRow(contMenu);
  }
}

class Ap1 extends app.Item {
  app.Application ap;

  app.WinMeta meta = new app.WinMeta()
    ..title = 'Test'
    ..icon = 'cms'
    ..width = 1000
    ..height = 800;

  cl_form.Form form;

  Ap1(this.ap) {
    wapi = new app.WinApp(ap)..load(meta, this);

    final c = new LayoutContainer();
    final menu = new cl_action.Menu(c.contMenu);

    form = new cl_form.Form();

    menu
      ..add(new cl_action.Button()
        ..setTitle('Save')
        ..addClass('important')
        ..addAction((e) {
          print(form.getValue());
        }))
      ..add(new cl_action.Button()..setTitle('Print'))
      ..add(new cl_action.Button()
        ..setTitle('Delete')
        ..addClass('warning'));

    // Create the forms
    final f1el = formLeft(form);
    final f2el = formLeft(form);
    final grdd = gridDebit();
    final grdc = gridCredit();
    form..add(grdd)..add(grdc);

    // Append to layout
    c.contTopLeft.append(f1el);
    c.contTopRight.append(f2el);
    c.contMiddleLeft.append(grdd);
    c.contMiddleRight.append(grdc);

    wapi.win.getContent().append(c, scrollable: true);
    wapi.render();
  }

  cl_gui.FormElement formLeft(cl_form.Form f) {
    final form = new cl_gui.FormElement(f)
      ..addRow('Invoice', [new cl_form.Input()..setName('document')])
      ..addRow('Date', [new cl_form.InputDate()..setName('date')])
      ..addRow('Payment Method', [new cl_form.Input()..setName('payment')]);

    return form;
  }

  void formRight() {}

  cl_form.GridData gridDebit() => new cl_form.GridData()
    ..setName('grid_debit')
    ..initGridHeader([
      new cl_form.GridColumn('account')
        ..title = 'Debit'
        ..type = (grid, row, cell, value) => new cl_form.RowEditCell(
            grid, row, cell, new cl_form.Input()..setValue(value)),
      new cl_form.GridColumn('name')
        ..title = 'Title'
        ..width = '100%',
      new cl_form.GridColumn('amount')
        ..title = 'Amount'
        ..type = (grid, row, cell, value) => new cl_form.RowEditCell(
            grid,
            row,
            cell,
            new cl_form.Input(new cl_form.InputTypeDouble())..setValue(value)),
    ]);

  cl_form.GridData gridCredit() => new cl_form.GridData()
    ..setName('grid_credit')
    ..initGridHeader([
      new cl_form.GridColumn('account')
        ..title = 'Credit'
        ..type = (grid, row, cell, value) => new cl_form.RowEditCell(
            grid, row, cell, new cl_form.Input()..setValue(value)),
      new cl_form.GridColumn('name')
        ..title = 'Title'
        ..width = '100%',
      new cl_form.GridColumn('amount')
        ..title = 'Amount'
        ..type = (grid, row, cell, value) => new cl_form.RowEditCell(
            grid,
            row,
            cell,
            new cl_form.Input(new cl_form.InputTypeDouble())..setValue(value)),
    ]);
}
