library test.cl.grid;

import 'package:centryl/app.dart' as cl_app;
import 'package:centryl/base.dart' as cl;

import '../../grid/test.dart';

class AppGrid extends cl_app.Item {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Grid4'
    ..icon = cl.Icon.assignment
    ..width = 1000
    ..height = 800;

  AppGrid(this.ap) {
    wapi = new cl_app.WinApp(ap)
      ..load(meta, this)
      ..render();

    wapi.win.getContent().append(grid4(), scrollable: true);
  }
}
