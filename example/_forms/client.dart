library application;

import 'dart:html';
import 'package:centryl/base.dart' as cl;
import 'package:centryl/forms.dart' as cl_form;

void main() {
  final el = new cl_form.InputDate();
  new cl.CLElement(document.body).append(el);
  el.setValue(new DateTime.now());
  print(el.getValue());
}
