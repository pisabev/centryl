library test.input;

import 'dart:async';

import 'package:centryl/action.dart' as action;
import 'package:centryl/app.dart' as app;
import 'package:centryl/base.dart' as base;
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as gui;

gui.FormElement run([app.Application ap]) {
  final f = new cl_form.Form();
  final gui.FormElement form = new gui.FormElement(f);

  f.onLoadEnd.listen((_) {
    print('done');
  });
  form.addSection('Inputs');
  inputNormal(form);
  inputRange(form);
  inputRange2(form);
  inputDisabled(form);
  inputValidationInput(form);
  inputValidationValue(form);
  inputSufixPrefix(form);
  inputCombo(form);
  form.addSection('DateTime Fields');
  dateField(form);
  dateFieldRange(form);
  dateTimeField(form);
  dateTimeFieldValid(form);
  dateTimeFieldFilter(form);
  dateTimeFields(form);
  dateRange(form);
  timeField(form);
  badgeField(form);
  form.addSection('Async Loaders and SelectBoxes');
  inputLoader(form);
  inputLoaderDisabled(form);
  select(form);
  selectDisabled(form);
  selectMulti(form);
  selectMultiAsync(form);
  selectAsync(form);
  selectAsyncDeps(form);
  form.addSection('CheckBox and Radio');
  checkBox(form);
  radio(form);
  radioGroup(form);
  form.addSection('Text Fields');
  textArea(form);
  if (ap != null) editor(form, ap);
  form.addSection('List check');
  listCheck(form);
  return form;
}

void inputNormal(gui.FormElement content) {
  final hint = new app.HintManager(
      (k) async =>
          'Hint message Hint message Hint message Hint message Hint message'
          ' Hint message Hint message Hint message Hint message Hint message',
      'right');
  final input = new cl_form.Input()
    ..setWarning(new base.DataWarning('first', 'First Warning'))
    ..setWarning(new base.DataWarning('first2', 'First Warning'))
//    ..setWarning(new base.DataWarning('first3', 'First Warning'))
//    ..setWarning(new base.DataWarning('first4', 'First Warning'))
//    ..setWarning(new base.DataWarning('first5', 'First Warning'))
//    ..setWarning(new base.DataWarning('first6', 'First Warning'))
//    ..setWarning(new base.DataWarning('first77', 'First Warning'))
//    ..setWarning(new base.DataWarning('first8', 'First Warning'))
//    ..setWarning(new base.DataWarning('first9', 'First Warning'))
//    ..setWarning(new base.DataWarning('first0', 'First Warning'))
//    ..setWarning(new base.DataWarning('first11', 'First Warning'))
//    ..setWarning(new base.DataWarning('first12', 'First Warning'))
//    ..setWarning(new base.DataWarning('first13', 'First Warning'))
//    ..setWarning(new base.DataWarning('first14', 'First Warning'))
    ..setWarning(new base.DataWarning('first15', 'First Warning'))
    ..setWarning(new base.DataWarning('second',
        'Second Warning with very very long long long message message message'))
    ..setWarning(new base.DataWarning('third', 'Third Warning'));
  content.addRow(hint.get('Input', 'test'), [input]);
  content.addRow(hint.get('Input String', 'test'), [
    new cl_form.Input(new cl_form.InputTypeString(length: [2, 3]))
  ]);
}

void inputRange(gui.FormElement content) {
  final inputr =
      new cl_form.Input(new cl_form.InputTypeInt(range: [0, 100], step: 20));
  final b = new action.Button()
    ..addAction((e) {
      inputr.setType(cl_form.InputTypeDouble(range: [0, 50], step: 10));
    })
    ..setTitle('Change to float');
  content.addRow('Input Range', [inputr, b]);
}

void inputRange2(gui.FormElement content) {
  final inputr = new cl_form.InputRange()..setValue(45);
  content.addRow('Input Range', [inputr]);
}

void inputDisabled(gui.FormElement content) {
  final inputd = new cl_form.Input()..disable();
  content.addRow('Input Disabled', [inputd]);
}

void inputValidationInput(gui.FormElement content) {
  final inputv = new cl_form.Input(new cl_form.InputTypeDouble())
    ..setPlaceHolder('Only Numbers');

  content.addRow('Validation on input', [inputv]);
}

void inputValidationValue(gui.FormElement content) {
  final inputvv = new cl_form.Input()
    ..setPlaceHolder('abc')
    ..addValidationOnValue((v) => v == 'abc');
  content.addRow('Validation on blur', [inputvv]);
}

void inputSufixPrefix(gui.FormElement content) {
  final inputs = new cl_form.Input()
    ..setSuffix('suffix')
    ..setPrefix('prefix');
  content.addRow('Sufix and Prefix', [inputs]);
}

void inputCombo(gui.FormElement content) {
  final inp = new cl_form.Input();
  final select = new cl_form.Select()
    ..addOption(null, 'Option null')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4');
  final select2 = new cl_form.Select()
    ..addOption(null, 'Option null')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4');
  inp
    ..setSuffixElement(select)
    ..setPrefixElement(select2);

  content.addRow('Input Combo', [inp]);
}

void dateField(gui.FormElement content) {
  final input = new cl_form.InputDate()..setValue(new DateTime.now());
  new Timer(new Duration(seconds: 1), () {
    input.setValue(null);
  });
  //input.setValue('2017-12-13T00:00:00.000Z');
  //input.setValue("2018-02-27T22:00:00.000Z");
  //input.setValue("2018-02-27T22:00:00.000");
  input.setValue('2018-02-27T00:00:00.000');
  input.onValueChanged.listen((r) {
    print('Date Filed changed');
    print(r.getValue());
  });
  content.addRow('Date Field', [input]);
}

void dateFieldRange(gui.FormElement content) {
  final d1 = new DateTime.now().subtract(new Duration(days: 30));
  final d2 = new DateTime.now().add(new Duration(days: 30));
  final input = new cl_form.InputDate(range: [
    DateTime.parse('2019-08-13 13:58:00.000Z'),
    DateTime.parse('2019-08-19 13:58:00.000Z')
  ], inclusive: true);
  content.addRow('Date Field Filter', [input]);
}

void dateTimeField(gui.FormElement content) {
  final input = new cl_form.InputDateTime()
    //input.setValue('2017-12-13T00:00:00.000Z');
    //input.setValue("2018-02-27T22:00:00.000Z");
    ..onValueChanged.listen((r) {
      print('Date Time Field changed');
      print(r.getValue());
    })
    ..setType(new cl_form.InputTypeDateTime(range: [
      DateTime.parse('2019-08-13 13:58:00.000Z'),
      DateTime.parse('2019-08-15 13:58:00.000Z')
    ], inclusive: true));

  content.addRow('Date Time Field', [input]);
}

void dateTimeFieldValid(gui.FormElement content) {
  final input = new cl_form.InputDateTime()
    ..setValue(new DateTime.now())
    ..onValueChanged.listen((e) {
      new Future.delayed(new Duration(seconds: 1), () {
        e.setValid(false);
      });
    });
  content.addRow('Date Time Field - Not Valid', [input]);
}

void dateTimeFieldFilter(gui.FormElement content) {
  final input = new cl_form.InputDateTime()
    ..addValidationOnValue((e) => e.isBefore(new DateTime.now()));
  content.addRow('Date Time Field - Filter', [input]);
}

void dateTimeFields(gui.FormElement content) {
  final input = new cl_form.InputDate();
  final time = new cl_form.InputTime();
  //input.setValue('2017-12-13T00:00:00.000Z');
  //input.setValue("2018-02-27T22:00:00.000Z");
  input
    ..setValue('2018-02-27T22:00:00.000')
    ..onValueChanged.listen((r) {
      print('Date Time Fields Date changed: ${r.getValue()}');
    });

  time.onValueChanged.listen((r) {
    print(r.getValue());
//    print('Date Time Fields Time changed: ${r.getValue()}');
//    if (r.getValue() != null) {
//      final dutc = input.getValue_();
//      final l = new DateTime(dutc.year, dutc.month, dutc.minute).toUtc();
//      print(l.add(new Duration(minutes: r.getValue())));
//    }
  });
  content.addRow('Date Time Fields', [input, time]);
}

void dateRange(gui.FormElement content) {
  final input = new cl_form.InputDateRange()
    ..setRequired(true)
    ..setValue([
      new DateTime.now().toIso8601String(),
      new DateTime.now().toIso8601String()
    ]);
  content.addRow('Date Range Field', [input]);
}

void timeField(gui.FormElement content) {
  final input = new cl_form.InputTime(canBeNull: true)
    ..onValueChanged.listen((e) {
      print(e.getValue());
    });
  content.addRow('Input Time Field', [input]);
}

void badgeField(gui.FormElement content) {
  final b = new cl_form.Badge()
    ..execute = (() async {
      await new Future.delayed(new Duration(milliseconds: 2000));
      return 'Badge Field With Loader';
    })
    ..load();
  content.addRow('Badge Field', [b]);
}

void inputLoader(gui.FormElement content) {
  final input = new cl_form.InputLoader()
    ..execute = (() async {
      await new Future.delayed(new Duration(seconds: 1));
      final List<Map> d = [];
      for (int i = 0; i < 10; i++) d.add({'k': i + 1, 'v': 'Option$i'});
      return d;
    })
    ..onLoadStart.listen((_) {
      print('Load started');
    })
    ..onLoadEnd.listen((_) {
      print('Load ended');
    });
  content.addRow('Input Loader', [input]);
}

void inputLoaderDisabled(gui.FormElement content) {
  final input = new cl_form.InputLoader()
    ..disable()
    ..execute = (() async {
      await new Future.delayed(new Duration(seconds: 1));
      final List<Map> d = [];
      for (int i = 0; i < 10; i++) d.add({'k': i + 1, 'v': 'Option$i'});
      return d;
    });
  content.addRow('Input Loader Disabled', [input]);
}

void select(gui.FormElement content) {
  final select = new cl_form.Select()
    ..addOption(null, 'Option null')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4')
    ..setValue(3);

  final select1 = new cl_form.Select()
    ..addOption(null, 'Option null')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4')
    ..setWarning(new base.DataWarning('test', 'greshka'))
    ..setValue(3);

  final select2 = new cl_form.Select()
    ..addOption(null, '')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2').addClass('warning')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4');

  //select.setValue(3);
  content
    ..addRow('Select Field', [select])
    ..addRow('Select Field1', [select1])
    ..addRow('Select Field2', [select2]);
}

void selectDisabled(gui.FormElement content) {
  final select = new cl_form.Select()
    ..disable()
    ..addOption(null, 'Option null')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4')
    ..setValue(3);

  content.addRow('Select Disabled', [select]);
}

void selectMulti(gui.FormElement content) {
  final select = new cl_form.SelectMulti()
    ..addOption(null, 'Option null')
    ..addOption(1, 'Option 1')
    ..addOption(2, 'Option 2')
    ..addOption(3, 'Option 3')
    ..addOption(4, 'Option very long long long long option 4')
    ..onValueChanged.listen((e) {
      print('select multi changed');
    })
    ..setValue([2, 4]);

  content.addRow('Select Multiple', [select]);
}

void selectMultiAsync(gui.FormElement content) {
  final select = new cl_form.SelectMulti()
    ..execute = () async {
      await new Future.delayed(new Duration(milliseconds: 3500));
      return [
        {'k': null, 'v': 'Option null'},
        {'k': 1, 'v': 'Option 1'},
        {'k': 2, 'v': 'Option 2'},
        {'k': 3, 'v': 'Option 3'},
        {'k': 4, 'v': 'Option 4'},
        {'k': 5, 'v': 'Option very long long long long option 4'}
      ];
    }
    ..setValue([2, 4]);
  content.addRow('Select Multiple Async', [select]);
}

void selectAsync(gui.FormElement content) {
  final select = new cl_form.Select()
    ..onValueChanged.listen((_) => print('changed'))
    ..execute = () async {
      await new Future.delayed(new Duration(milliseconds: 3500));
      return [
        {'k': null, 'v': 'Option null'},
        {'k': 1, 'v': 'Option 1'},
        {'k': 2, 'v': 'Option 2'},
        {'k': 3, 'v': 'Option 3'},
        {'k': 4, 'v': 'Option 4'},
        {'k': 5, 'v': 'Option very long long long long option 4'}
      ];
    };

  content.addRow('Select Field (Loading)', [select]);
  select.setValue(4);
}

void selectAsyncDeps(gui.FormElement content) {
  final select1 = new cl_form.Select()
    ..setName('Dep1')
    ..onValueChanged.listen((_) => print('changed'))
    ..execute = () async {
      await new Future.delayed(new Duration(milliseconds: 1500));
      return [
        {'k': null, 'v': 'Option null'},
        {'k': 1, 'v': 'Option 1'},
        {'k': 2, 'v': 'Option 2'},
        {'k': 3, 'v': 'Option 3'},
        {'k': 4, 'v': 'Option 4'},
        {'k': 5, 'v': 'Option very long long long long option 4'}
      ];
    };

  final select2 = new cl_form.Select()
    ..setName('Dep2')
    ..onValueChanged.listen((_) => print('changed'))
    ..dependOn(select1);

  select2.execute = () async {
    select2.dependencies.forEach(
        (dep) => print('Select2: ${dep.getName()} - ${dep.getValue()}'));

    await new Future.delayed(new Duration(milliseconds: 1500));
    return [
      {'k': null, 'v': 'Option null'},
      {'k': 1, 'v': 'Option 1'},
      {'k': 2, 'v': 'Option 2'},
      {'k': 3, 'v': 'Option 3'},
      {'k': 4, 'v': 'Option 4'},
      {'k': 5, 'v': 'Option very long long long long option 4'}
    ];
  };

  final select3 = new cl_form.Select()
    ..onValueChanged.listen((_) => print('changed'))
    ..dependOn(select1)
    ..dependOn(select2);

  select3.execute = () async {
    select3.dependencies.forEach(
        (dep) => print('Select3: ${dep.getName()} - ${dep.getValue()}'));
    await new Future.delayed(new Duration(milliseconds: 1000));
    return [
      {'k': null, 'v': 'Option null'},
      {'k': 1, 'v': 'Option 1'},
      {'k': 2, 'v': 'Option 2'},
      {'k': 3, 'v': 'Option 3'},
      {'k': 4, 'v': 'Option 4'},
      {'k': 5, 'v': 'Option very long long long long option 4'}
    ];
  };

  content
    ..addRow('Select Field (Dep1)', [select1])
    ..addRow('Select Field (Dep2)', [select2])
    ..addRow('Select Field (Dependee)', [select3]);

  select1.setValue(4);
  select2.setValue(5);
  select3.setValue(2);
}

void checkBox(gui.FormElement content) {
  final check = new cl_form.Check('bool');
  check.onValueChanged.listen((_) {
    print('checked changed ${check.getValue()}');
  });

  //check.setValue()
  final check1 = new cl_form.Check()..setLabel('label');
  final checkd = new cl_form.Check()
    ..disable()
    ..setLabel('label');
  final checkd2 = new cl_form.Check()
    ..disable()
    ..setValue(true)
    ..setLabel('label');
  content.addRow('CheckBox Field', [check, check1, checkd, checkd2]);
}

void radio(gui.FormElement content) {
  final check = new cl_form.Radio();
  final check1 = new cl_form.Radio()..setLabel('label');
  final checkd = new cl_form.Radio()
    ..disable()
    ..setLabel('label');
  final checkd2 = new cl_form.Radio()
    ..click()
    ..disable()
    ..setLabel('label');
  content.addRow('Radio Field', [check, check1, checkd, checkd2]);
}

void radioGroup(gui.FormElement content) {
  final check = new cl_form.Radio()
    ..setLabel('label1')
    ..setValue('value1')
    ..onValueChanged.listen((_) => print('label1 changed'));

  final check1 = new cl_form.Radio()
    ..setLabel('label2')
    ..setValue('value2')
    ..onValueChanged.listen((_) => print('label2 changed'));

  final check2 = new cl_form.Radio()
    ..setLabel('label3')
    ..setValue('value3')
    ..onValueChanged.listen((_) => print('label3 changed'));

  new cl_form.RadioGroup('mygroup')
    ..registerElement(check)
    ..registerElement(check1)
    ..registerElement(check2)
    ..onValueChanged.listen((e) => print(e.getValue()));

  content.addRow('RadioGroup Field', [check, check1, check2]);
}

void textArea(gui.FormElement content) {
  final area = new cl_form.TextArea()
    ..onValueChanged.listen((_) => print('changed Text Area'));

  content.addRow('Text Area', [area]);
}

void editor(gui.FormElement content, app.Application ap) {
  final area = new cl_form.Editor(ap)
    ..onValueChanged.listen((_) => print('changed'));

  content.addRow('Text Area', [area]);
}

void listCheck(gui.FormElement content) {
  final chekcs = new cl_form.CheckList()
    ..cols = 4
    ..execute = (() async => [
          {'k': 'first', 'v': 'First'},
          {'k': 'second', 'v': 'Second'},
          {'k': 'third', 'v': 'Third'},
          {'k': 'forth', 'v': 'Forth'}
        ])
    ..setValue(['first'])
    ..onValueChanged.listen((_) => print('changed Text Area'));

  content.addRow('List Checks', [chekcs]);
}
