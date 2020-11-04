import 'dart:async';

import 'package:centryl/app.dart' as cl_app;

import 'intl/client.dart' as intl;
import 'src/path.dart';

void init(cl_app.Application ap) {
  cl_app.NotificationMessage.registerDecorator(
      Routes.eventServerStop,
      (not) => not
        ..priority = cl_app.NotificationMessage.error
        ..text = intl.Platform_stopped());
  cl_app.NotificationMessage.registerDecorator(
      Routes.eventServerStart,
      (not) => not
        ..priority = cl_app.NotificationMessage.info
        ..text = intl.Platform_started());
  cl_app.NotificationMessage.registerDecorator(
      Routes.eventServerUpdate,
      (not) => not
        ..priority = cl_app.NotificationMessage.warning
        ..text = intl.Platform_updated());
  cl_app.NotificationMessage.registerDecorator(
      Routes.eventServerUpdater,
      (not) => not
        ..priority = cl_app.NotificationMessage.error
        ..text = intl.Platform_updated_refresh());
  ap.onServerCall.filter(Routes.eventServerStop).listen((res) {
    ap.notify.add(new cl_app.NotificationMessage.fromMap(res));
  });
  ap.onServerCall.filter(Routes.eventServerStart).listen((res) {
    ap.notify.add(new cl_app.NotificationMessage.fromMap(res));
  });
  ap.onServerCall.filter(Routes.eventServerUpdate).listen((res) {
    ap.notify.add(new cl_app.NotificationMessage.fromMap(res));
  });
  ap.onServerCall.filter(Routes.eventServerUpdater).listen((res) {
    ap.notify.add(new cl_app.NotificationMessage.fromMap(res));
    new Timer(const Duration(seconds: 10),
        () => ap.reboot(const Duration(seconds: 60)));
  });
}
