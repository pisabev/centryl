import 'dart:html';
import 'package:centryl/app.dart' as app;
import 'package:centryl/base.dart' as cl;
import 'package:centryl/action.dart' as action;

late app.Application ap;

void init() {
  ap = new app.Application(settings: new app.AppSettings())
    //ap.setAbout('packages/centryl/images/icons/centryl.svg', null);
    ..setClient(new app.Client({
      'client': {'name': 'test'}
    })
      ..addApp(new app.ClientApp()
        ..init = (ap) => new action.Button()
          ..setIcon(cl.Icon.exit_to_app)
          ..addAction((e) => window.alert('logout'))
          ..setTitle('Logout'))
      ..addApp(new app.ClientApp()
        ..init = (ap) => new action.Button()
          ..setIcon(cl.Icon.settings)
          ..addAction((e) => window.alert('settings'))
          ..setTitle('Settings')))
    ..done();
}
