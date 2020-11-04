@JS()
library chat;

import 'dart:async';
import 'dart:html' hide Dimension;
import 'dart:typed_data';
import 'dart:web_audio';

import 'package:js/js.dart';
import 'package:pdf/pdf.dart';

import '../../intl/client.dart' as intl;
import 'action.dart' as action;
import 'app.dart' as app;
import 'base.dart';
import 'forms.dart' as form;
import 'utils.dart' as utils;

part 'chat/chat.dart';
part 'chat/controller.dart';
part 'chat/media.dart';
part 'chat/member.dart';
part 'chat/message.dart';
part 'chat/message_decorator.dart';
part 'chat/peer_connection.dart';
part 'chat/peer_manager.dart';
part 'chat/room.dart';
part 'chat/room_context.dart';
part 'chat/room_list_context.dart';
part 'chat/rtc_request.dart';
