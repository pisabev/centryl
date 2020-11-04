library test.win;

//import 'dart:async';
//import 'dart:html';
import 'package:centryl/base.dart';
import 'package:centryl/app.dart' as cl_app;
//import 'package:centryl/forms.dart' as cl_form;
//import 'package:centryl/gui.dart' as gui;

const String html = '''
  <h2>Title</h2>
  <p>Lorem Ipsum is simply dummy text of the printing and typesetting industry.
   Lorem Ipsum has been the industry\'s standard dummy text ever since the 
   1500s, when an unknown printer took a galley of type and scrambled it to
    make a type specimen book. It has survived not only five centuries,
     but also the leap into electronic typesetting, remaining essentially 
     unchanged. It was popularised in the 1960s with the release of Letraset 
     sheets containing Lorem Ipsum passages, and more recently with desktop 
     publishing software like Aldus PageMaker including versions of Lorem
      Ipsum</p>
  <p>Lorem Ipsum is simply dummy text of the printing and typesetting
   industry. Lorem Ipsum has been the industry\'s standard dummy text ever
    since the 1500s, when an unknown printer took a galley of type and 
    scrambled it to make a type specimen book. It has survived not only
     five centuries, but also the leap into electronic typesetting,
      remaining essentially unchanged. It was popularised in the 1960s 
      with the release of Letraset sheets containing Lorem Ipsum passages,
       and more recently with desktop publishing software like Aldus 
       PageMaker including versions of Lorem Ipsum</p>
''';

void runDialog(cl_app.Application ap) {
  final cont = new Container()
    ..addClass('ui-row')
    ..auto = true
    ..setHtml(html);
  new cl_app.Dialog(ap, cont)
    ..title = 'Test'
    ..render();
}

void runConfirmer(cl_app.Application ap) {
  final cont = new Container()
    ..addClass('ui-row')
    ..auto = true
    ..setHtml(html);
  new cl_app.Confirmer(ap, cont)
    ..title = 'Test'
    ..onOk = (() => true)
    ..render();
}

void runQuestion(cl_app.Application ap) {
  final cont = new Container()
    ..addClass('ui-row')
    ..auto = true
    ..setHtml(html);
  new cl_app.Questioner(ap, cont)
    ..title = 'Test'
    ..onNo = (() {
      print('no');
      return true;
    })
    ..onYes = (() {
      print('yes');
      return true;
    })
    ..render();
}