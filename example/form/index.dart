library test;

import 'dart:async';
import 'dart:html';

import 'package:centryl/action.dart' as cl_action;
import 'package:centryl/app.dart' as app;
import 'package:centryl/base.dart';
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as cl_gui;

import '../common/base.dart';

void main() {
  init();
  form1();
  formDisable();
  form2();
  formList();
}

void form2() {
  final w = new app.Win(ap.desktop);
  final content = new Container();
  w.getContent()
    ..addRow(new Container())
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_gui.FormElement()..addClass('top');
  final hint =
      new app.HintManager((k) async => 'Hint message', 'right'); //String

  final e1 = form
      .addRow(hint.get('Ro1', 'key'), [new cl_form.Input()..setName('key1')]);
  final e2 = form.addRow('Row2', [new cl_form.Input()..setName('key2')]);
  final e3 =
      form.addRow('Row3 Row2 Row2', [new cl_form.Input()..setName('key3')]);
  final e4 = form.addRow('Row3', [new cl_form.Input()..setName('key3')]);
  final e5 = form.addRow('Row3', [new cl_form.Input()..setName('key3')]);
  final e6 =
      form.addRow('Row3 long long', [new cl_form.Input()..setName('key3')]);
  final e7 = form.addRow('Row3', [new cl_form.Input()..setName('key3')]);
  final e8 = form.addRow('Row3', [new cl_form.Input()..setName('key3')]);
  final e9 = form.addRow('Row3', [new cl_form.Input()..setName('key3')]);
  final e10 = form.addRow('Row3', [new cl_form.Input()..setName('key3')]);

  e1.addClass('col2');
  e2.addClass('col2');
  e3.addClass('col2');
  e4.addClass('col2');
  e5.addClass('col4');
  e6.addClass('col1');
  e7.addClass('col1');
  e8.addClass('col1');
  e9.addClass('col1');
  e10.addClass('col3');
  content.append(form);
}

void form1() {
  final w = new app.Win(new CLElement(document.body));
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final f = new cl_form.Form();
  final form = new cl_gui.FormElement(f);
  f.onValueChanged.listen(print);

  form
    ..addRow('Row1', [
      new cl_form.Input()
        ..setName('key1')
        ..addClass('max')
    ])
    ..addRow('Row2', [new cl_form.Input()..setName('key2')])
    ..addRow('Lorem ipsum long title very very long', [
      'some',
      new cl_form.Check(),
      new cl_form.Input()
        ..setName('key3')
        ..addClass('max'),
      'some',
      new cl_form.Input()..setName('key4')
    ])
    ..addRow('Row3', [getForm(f)])
    ..addRow('row4', [
      new cl_gui.LabelField('label2', [new cl_form.Input()..setName('lbl1')]),
      new cl_gui.LabelField('label2', [
        new cl_form.Input()
          ..setSuffix('suffix')
          ..setName('lbl2')
      ])
    ]);

  content.append(form);

  f.setValue(
      {'key1': 'text1', 'key2': 'text2', 'key3': 'text3', 'key4': 'text4'});

  print(f.getValue());
  f.setValue(null);
}

void formDisable() {
  final w = new app.Win(new CLElement(document.body));
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final f = new cl_form.Form();
  final form = new cl_gui.FormElement(f);
  f.onValueChanged.listen(print);

  form
    ..addRow('Row1', [
      new cl_form.Input()
        ..setName('key1')
        ..addClass('max')
    ])
    ..addRow('Row2', [new cl_form.Input()..setName('key2')])
    ..addRow('Row3', [getForm(f)])
    ..addRow('row4', [
      new cl_gui.LabelField('label2', [new cl_form.Input()..setName('lbl1')]),
      new cl_gui.LabelField('label2', [
        new cl_form.Input()
          ..setSuffix('suffix')
          ..setName('lbl2')
      ])
    ]);

  final gr = new cl_form.GridData()..setName('grid');

  gr
    ..initGridHeader([
      new cl_form.GridColumn('first')..title = 'First',
      new cl_form.GridColumn('second')..title = 'Second',
      new cl_form.GridColumn('third')..title = 'Third',
      new cl_form.GridColumn('del')..title = 'Delete'
    ])
    ..addHookRow((r, o) {
      o['first'] = new cl_form.Input()..setValue(o['firts']);
      o['second'] = new cl_form.Input()..setValue(o['second']);
      o['del'] = new cl_action.Button()
        ..setIcon('remove')
        ..addAction((e) {
          gr.rowRemove(r);
        });
    });
  form.addRow('Grid Data', [gr]);

  final gr2 = new cl_form.GridForm()..setName('grid2');
  gr2.addHookRow((node, o) {
    node.form.addRow('First', [new cl_form.Input()]);
    node.form.addRow('Second', [new cl_form.Input()]);
    node.form.addRow('Third', [new cl_form.Text()]);
    node.form.addRow('Delete', [
      new cl_action.Button()
        ..setIcon('remove')
        ..addAction((e) {
          gr2.nodeRemove(node);
        })
    ]);
  });

  form.addRow('Grid Form', [gr2]);

  content.append(form, scrollable: true);

  f.setValue({
    'key1': 'text1',
    'key2': 'text2',
    'key3': 'text3',
    'key4': 'text4',
    'grid': [
      <String, dynamic>{
        'first': 'f_text',
        'second': 's_text',
        'third': 't_text'
      }
    ],
    'grid2': [
      <String, dynamic>{
        'first': 'f_text',
        'second': 's_text',
        'third': 't_text'
      }
    ]
  });

  print(f.getValue());
  //f.disable();
  //new Future.delayed(new Duration(seconds:2)).then((_) => f.disable());
}

cl_gui.FormElement getForm(cl_form.Form f) => new cl_gui.FormElement(f)
  ..addRow('Row1', [
    new cl_form.Input()
      ..setName('key11')
      ..addClass('max')
  ])
  ..addRow('Row2', [new cl_form.Input()..setName('key22')])
  ..addRow('Row2', [
    new cl_form.Input()..setName('key33'),
    new CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key44')
  ]);

cl_gui.FormElement getFormC(cl_form.Form f) => new cl_gui.FormElement(f)
  ..addRow('Row1', [
    new cl_form.Input()
      ..setName('key1')
      ..addClass('max')
  ])
  ..addRow('Row2', [new cl_form.Input()..setName('key2')])
  ..addRow('Row2', [
    new cl_form.Input()..setName('key3'),
    new CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key4')
  ]);

void formList() {
  final w = new app.Win(new CLElement(document.body));
  final content = new Container();
  w.getContent()
    ..addRow(new Container()..addClass('top'))
    ..addRow(content..auto = true)
    ..addRow(new Container()..addClass('bottom'));
  w.render(700, 700);

  final form = new cl_form.GridForm();

  form
    ..drag = true
    ..fullData = true
    ..num = true
    ..addHookRow((r, o) {
      final s = new Select();
      //r.form.formInner.add(new cl_form.Data()..setName('position'));
      r.form
        ..addRow('Select', [
          s
            ..load()
            ..setName('select')
        ])
        ..addRow('Select2', [
          new Select2()
            ..dependOn(s)
            ..setName('select2')
        ])
        //r.form.addRow('Loader', [new InputLoader()
        // ..dependOn(s)..setName('loader')]);
        ..addRow('remove', [
          new cl_action.Button()
            ..setIcon('delete')
            ..addAction((e) {
              form.nodeRemove(r);
            })
        ]);
    })
    ..setValue([
      {'select': 1, 'select2': 1},
    ]);
  form.onValueChanged.listen((_) {
    print('here');
  });

  content
    ..append(form)
    ..append(new cl_action.Button()
      ..setTitle('Print Data')
      ..addAction((e) {
        print(form.getValue());
      }));
}

class Select extends cl_form.Select {
  Select() : super() {
    execute = () async {
      await new Future.delayed(new Duration(seconds: 1));
      return [
        {'k': 1, 'v': '1'},
        {'k': 2, 'v': '2'}
      ];
    };
  }
}

class Select2 extends cl_form.Select {
  Select2() : super() {
    execute = () async {
      await new Future.delayed(new Duration(seconds: 2));
      if (dependencies.first.getValue() == 1)
        return [
          {'k': 1, 'v': '1'}
        ];
      else
        return [];
    };
  }
}

class InputLoader extends cl_form.InputLoader {
  InputLoader() : super() {
    execute = () async {
      await new Future.delayed(new Duration(seconds: 2));
      if (dependencies.first.getValue() == 1)
        return [
          {'k': 1, 'v': '1'}
        ];
      else
        return [];
    };
  }
}
