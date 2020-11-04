library test.accordion;

//import 'dart:async';
import 'dart:html';
import 'package:centryl/base.dart' as cl;
import 'package:centryl/forms.dart' as cl_form;
import 'package:centryl/gui.dart' as gui;

gui.Accordion run(dynamic ap) {
  final ac = new gui.Accordion()..setStyle({'margin': '10px'});
  ac.createNode('first')
    .contentDom.append(new ParagraphElement()..text = 'content');
  ac.createNode('second')
    .contentDom.append(new ParagraphElement()..text = 'content2');
  ac.createNode('third')
    .contentDom.append(getForm(new cl_form.Form()));
  ac.createNode('forth')
    .contentDom.append(new ParagraphElement()..text = 'content3');
  return ac;
}

gui.FormElement getForm(cl_form.Form f) {
  final form = new gui.FormElement(f)
    ..addRow('Row1', [new cl_form.Input()
      ..setName('key1')])
    ..addRow('Row2', [new cl_form.Input()..setName('key2')])
    ..addRow('Row2', [
    new cl_form.Input()..setName('key3'),
    new cl.CLElement(new SpanElement())..setText('some'),
    new cl_form.Input()..setName('key4')]);

  return form;
}