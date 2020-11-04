library test.action;

//import 'dart:async';
//import 'dart:html';
//import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/base.dart' as base;
import 'package:centryl/gui.dart' as gui;
import 'package:centryl/action.dart' as cl_action;

gui.FormElement run() {
  final gui.FormElement form = new gui.FormElement();

  inputButton(form);
  inputButtonTypes(form);
  inputButtonIcon(form);
  inputButtonGroup(form);
  inputButtonOption(form);
  inputButtonOption2(form);
  state(form);
  return form;
}

void inputButton(gui.FormElement content) {
  final but = new cl_action.Button()
    ..setIcon(base.Icon.attach_file)
    ..setTitle('Attach File')
    ..setTip('Some tip')
    ..setWarning(new base.DataWarning('test', 'test message'));
  content.addRow('Button', [but]);
}

void inputButtonTypes(gui.FormElement content) {
  final but0 = new cl_action.Button()
    ..addClass('light')
    ..setIcon(base.Icon.attach_file)
    ..setTitle('Attach File');
  final but = new cl_action.Button()
    ..setIcon(base.Icon.attach_file)
    ..setTitle('Attach File');
  final but1 = new cl_action.Button()
    ..setIcon(base.Icon.attach_file)
    ..addClass('important')
    ..setTitle('Attach File');
  final but2 = new cl_action.Button()
    ..setIcon(base.Icon.attach_file)
    ..addClass('warning')
    ..setTitle('Attach File')
    ..setWarning(new base.DataWarning('test', 'test message'));
  final but3 = new cl_action.Button()
    ..setIcon(base.Icon.attach_file)
    ..addClass('attention')
    ..setTitle('Attach File');
  content.addRow('Button Types', [but0, but, but1, but2, but3]);
}

void inputButtonIcon(gui.FormElement content) {
  final but = new cl_action.Button()..setIcon(base.Icon.attach_file);
  content.addRow('Icon Button', [but]);
}

void inputButtonGroup(gui.FormElement content) {
  final grp = new cl_action.ButtonGroup()
    ..addSub(new cl_action.Button()..setTitle('test'))
    ..addSub(new cl_action.Button()..setTitle('test2'))
    ..addSub(new cl_action.Button()..setTitle('test3'));
  content.addRow('Button Group', [grp]);
}

void inputButtonOption(gui.FormElement content) {
  final grp = new cl_action.ButtonOption()
    ..setDefault(new cl_action.Button()..setTitle('Main'))
    ..addSub(new cl_action.Button()
      ..setIcon(base.Icon.print)
      ..setTitle('test'))
    ..addSub(new cl_action.Button()
      ..disable()
      ..setIcon(base.Icon.today)
      ..setTitle('test2 longer title button'))
    ..addSub(new cl_action.Button()
      ..setIcon(base.Icon.attach_file)
      ..setTitle('test3'));

  content.addRow('Button Options', [grp]);
}

void inputButtonOption2(gui.FormElement content) {
  final grp = new cl_action.ButtonOption()
    ..buttonOption
    ..setTitle('Test')
    ..addSub(new cl_action.Button()
      ..setIcon(base.Icon.print)
      ..setTitle('test'))
    ..addSub(new cl_action.Button()
      ..disable()
      ..setIcon(base.Icon.today)
      ..setTitle('test2 longer title button'))
    ..addSub(new cl_action.Button()
      ..setIcon(base.Icon.attach_file)
      ..setTitle('test3'));

  content.addRow('Button Options 2', [grp]);
}

void state(gui.FormElement content) {
  final grp = new gui.LabelState(['First', 'Second', 'Third', 'Forth'])
    ..setActive(0)
    ..setClickable([0, 1, 2, 3]);
  grp.onChange.listen(print);
  grp
    ..disable()
    ..enable();
  content.addRow('States', [grp]);
}
