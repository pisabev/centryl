library test.cl.action;

import 'package:centryl/app.dart' as cl_app;
import 'package:centryl/base.dart' as cl;

import '../../action/test.dart';

class AppActions extends cl_app.Item {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Actions'
    ..icon = cl.Icon.assignment
    ..width = 1000
    ..height = 800;

  AppActions(this.ap) {
    wapi = new cl_app.WinApp(ap)
      ..load(meta, this)
      ..render();

    wapi!.win.getContent().append(run(), scrollable: true);
  }
}
