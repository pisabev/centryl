library app;

import 'dart:async';
import 'dart:convert';
import 'dart:html' hide Dimension;
import 'dart:math' as math;

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:collection/collection.dart';

import '../../intl/client.dart' as intl;
import '../dto.dart' as dto;
import 'action.dart' as action;
import 'base.dart';
import 'chart.dart' as chart;
import 'forms.dart' as forms;
import 'utils.dart' as utils;

part 'app/application.dart';
part 'app/client.dart';
part 'app/clock.dart';
part 'app/confirmer.dart';
part 'app/dialog.dart';
part 'app/gadget.dart';
part 'app/hint.dart';
part 'app/icon_manager.dart';
part 'app/menu.dart';
part 'app/message_bus.dart';
part 'app/notification_message.dart';
part 'app/notify.dart';
part 'app/questioner.dart';
part 'app/registry.dart';
part 'app/route.dart';
part 'app/win.dart';
part 'app/win_app.dart';
part 'app/win_manager.dart';

String getCodeMirrorTheme(Application ap) {
  var settings = ap.client.settings;
  settings ??= {};
  return settings['theme'] == 'dark' ? 'ambiance' : 'neo';
}
