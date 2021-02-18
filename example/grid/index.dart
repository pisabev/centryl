library test;

import 'dart:async';

import 'package:centryl/action.dart' as cl_action;
import 'package:centryl/app.dart' as app;
import 'package:centryl/base.dart';
import 'package:centryl/forms.dart' as cl_form;
import 'dart:math';

import '../common/base.dart';
import 'test.dart';

void main() {
  init();
  //grid1();
  grid2();
//   grid3();
  //grid4();
//  grid5();
 // grid6();
}

void grid1() {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_form.GridList()
    ..initGridHeader([
      new cl_form.GridColumn('test')..title = 'test',
      new cl_form.GridColumn('product')..title = 'product'
    ]);
  final d = <Map>[];
  for (var i = 0; i < 50000; i++) {
    d.add({'test': 'test$i', 'product': 'product$i'});
  }
  content.append(form, scrollable: true);
  form.renderIt(d);
}

void grid2() {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_form.GridData(new cl_form.RenderBuffered());
  form
    ..initGridHeader([
      new cl_form.GridColumn('test')..title = 'test',
      new cl_form.GridColumn('product')..title = 'product',
      new cl_form.GridColumn('test2')
        ..title = 'test2'
        ..type = (grid, row, cell, value) => new cl_form.RowEditCell(
            grid, row, cell, new cl_form.Input()..setValue(value)),
    ])
    ..addHookRow((row, obj) {
      obj['product'] = new cl_action.Button()..setTitle('test button');
    })
    ..addHookRowAfter((row, obj) {
      final r = form.rowToMap(row);
      final b = r['product'] as cl_action.Button;
      print(b);
    });
  final d = <Map>[];
  for (var i = 0; i < 1000; i++) {
    d.add({'test': 'test$i', 'test2': 'sd', 'product': 'product$i'});
  }
  final cont = new cl_form.GridListContainer(form, auto: true);
  content.append(cont);
  form.renderIt(d);
}

void grid3() async {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_form.GridList(new cl_form.RenderBuffered())
    ..initGridHeader([
      new cl_form.GridColumn('test')
        ..width = '30%'
        ..title = 'test'
        ..group = 'FirstGroup',
      new cl_form.GridColumn('product')
        ..title = 'product'
        ..group = 'FirstGroup',
      new cl_form.GridColumn('test')
        ..title = 'test2'
        ..group = 'SecondGroup',
      new cl_form.GridColumn('product')
        ..title = 'product2'
        ..group = 'SecondGroup',
      new cl_form.GridColumn('total')
        ..title = 'total'
        ..group = 'SecondGroup'
        ..aggregator = new cl_form.NumAggregator()
    ]);

  final cont =
  new cl_form.GridListContainer(form, auto: true, fixedFooter: true);
  content.append(cont);

  final d = <Map>[];
  for (var i = 0; i < 100; i++) {
    int r = new Random().nextInt(50);
    final sb = new StringBuffer();
    while(r > 0) sb.write('test${r--} ');
    d.add({'test': '$sb', 'product': 'product$i', 'total': i});
  }

  form.renderIt(d);
}

class InputCountry extends cl_form.InputLoader {
  InputCountry() : super() {
    execute = () async {
      await new Future.delayed(new Duration(seconds: 1));
      final l = [
        {'k': 'first', 'v': 'First'},
        {'k': 'second', 'v': 'Second'}
      ];
      if (getSuggestion().isEmpty) return [l.first];
      return l;
    };
    domAction.addAction((e) {
      print('clicked');
    });
  }
}

class SelectCell extends cl_form.Select {
  SelectCell() : super() {
    execute = () async {
      await new Future.delayed(new Duration(seconds: 2));
      return [
        {'k': 1, 'v': 'FFFF'},
        {'k': 2, 'v': 'FSDSAD'}
      ];
    };
  }
}

void grid5() {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_form.GridData();
  form
    ..initGridHeader([
      new cl_form.GridColumn('test')..title = 'test',
      new cl_form.GridColumn('product')..title = 'product'
    ])
    ..addHookRow((row, obj) {
      obj['test'] = new cl_action.Button()..setTitle('test');
    })
    ..addHookRowAfter((row, obj) {
      final r = form.getRowMap(row);
      final b = r['test'].object as cl_action.Button;
      print(b);
    });
  final d = <Map>[];
  for (var i = 0; i < 10; i++) {
    d.add({'test': 'test$i', 'product': 'product$i'});
  }
  content.append(form, scrollable: true);
  form.renderIt(d);
}

void grid6() {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_form.GridForm()
    ..addHookRow((row, obj) {
      row.form
        ..addRow('First Row', [new cl_form.Input()..setName('key1')])
        ..addRow('Second Row', [new cl_form.Input()..setName('key2')])
        ..setValue(obj);
    });
  final d = <Map>[
    {'key1': 'test', 'key2': 'test2'},
    {'key1': 'test2', 'key2': 'test22'}
  ];
  form.setValue(d);
  content.append(form, scrollable: true);
}
