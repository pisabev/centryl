library test.cl.input;

import 'package:centryl/app.dart' as cl_app;
import 'package:centryl/base.dart' as cl;

import '../../input/test.dart';

class AppInputs extends cl_app.Item {
  cl_app.Application ap;
  cl_app.WinMeta meta = new cl_app.WinMeta()
    ..title = 'Inputs'
    ..icon = cl.Icon.file_archive
    ..width = 1000
    ..height = 800;

  AppInputs(this.ap) {
    wapi = new cl_app.WinApp(ap)
      ..load(meta, this)
      ..render();

    wapi.win.getContent().append(run(ap), scrollable: true);
  }
}
