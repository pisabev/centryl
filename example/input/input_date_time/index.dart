library test;

import 'package:centryl/develop.dart';
import 'package:centryl/forms.dart';
import 'package:centryl/gui.dart';

FormElement form;

void main() {
  final app = initApp();
  form = new FormElement()
    ..addClass('top')
    ..setStyle({'max-width': '400px'});
  app.gadgetsContainer.append(form);

  test();
  test2();
  test3();
  test4();
  test5();
}

void test() {
  final d = new DateTime.now();
  form.addRow('Valid after $d', [
    new InputDateTime()
      ..onValueChanged.listen(print)
      ..addValidationOnValue<DateTime>((e) => e.isAfter(d))
  ]);
}

void test2() {
  final d = new DateTime.now();
  form.addRow('Valid till $d', [
    new InputDateTime()
      ..addValidationOnValue<DateTime>((e) => e.isBefore(d))
  ]);
}

void test3() {
  form.addRow('Valid even dates', [
    new InputDateTime()..addValidationOnValue<DateTime>((e) => e.day % 2 == 0)
  ]);
}

void test4() {
  final d1 = new DateTime.now().subtract(new Duration(days: 2));
  final d2 = new DateTime.now().add(new Duration(days: 2));
  form.addRow('Valid between $d1 and $d2', [
    new InputDateTime(range: [d1, d2])
  ]);
}

void test5() {
  final d1 = new DateTime.now().subtract(new Duration(days: 2));
  final d2 = new DateTime.now().add(new Duration(days: 2));
  form.addRow('Valid between $d1 and $d2 (inclusive)', [
    new InputDateTime(range: [d1, d2], inclusive: true)
  ]);
}