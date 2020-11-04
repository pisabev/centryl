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
}

void test() {
  final d = new DateTime.now();
  form.addRow('Date Range', [
    new InputDateRange()
      ..onValueChanged.listen((e) => print(e.getValue()))
      ..setValue(['2020-04-01 21:00:00.000Z', '2020-04-15 21:00:00.000Z'])
  ]);
}