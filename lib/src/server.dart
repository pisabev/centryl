library cl_base.svc.server;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:communicator/server.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:csv/csv.dart' as csv;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import 'package:mapper/mapper.dart' as mapper;
import 'package:path/path.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:task/task.dart';

import 'mapper.dart';
import 'path.dart';

part 'svc/csv.dart';
part 'svc/file_sync.dart';
part 'svc/ics.dart';
part 'svc/mail.dart';
part 'svc/manager.dart';
part 'svc/pdf.dart';
part 'svc/service.dart';
part 'svc/sservice.dart';
part 'svc/tree.dart';
part 'svc/xls.dart';

final List<void Function(Router)> routes = [];
final List<FutureOr<void> Function(Map)> boot_call = [];

WSRouter _wsrouter;
final List<Client> _extraClients = [];

const String $meta = 'base_meta';

Meta meta;

String path = '.';
String baseURL = '/centryl';
String appTitle = 'Centryl';
String version = 'Centryl Framework v2.0';
Map config;
bool anonymousLogin = false;

bool devmode = false;
final Logger log = new Logger('Base');
final SNotificator notificator = new SNotificator();

Future<bool> Function(HttpRequest req) onclose = (req) async => true;

void Function(String group, String scope, List<String> access,
        [bool defaultValue]) permissionRegister =
    (group, scope, access, [defaultValue = false]) => null;

bool Function(Map session, String group, String scope, String access)
    permissionCheck = (session, group, scope, access) => true;

String Function(String group, String scope, String access) permissionMessage =
    (group, scope, access) => '';

void permissionRegisterStandardPack(String group, String scope,
    [bool defaultValue = false]) {
  permissionRegister(group, scope, [$RunRights.read], defaultValue);
  permissionRegister(group, scope, [$RunRights.create], defaultValue);
  permissionRegister(group, scope, [$RunRights.update], defaultValue);
  permissionRegister(group, scope, [$RunRights.delete], defaultValue);
}

class Meta {
  final String host;
  final String build;

  Meta(this.host, this.build);
}

Future<T> dbWrap<T>(Future<T> Function(mapper.Manager) function) async {
  final manager = await new mapper.Database().init();
  try {
    return await function(manager);
  } finally {
    await manager.close();
  }
}

Future<void> loadMeta() => dbWrap<void>((manager) async {
      final result = await manager.query('select * from ${$meta}');
      final data = result.first;
      meta = new Meta(data['host'], data['build']);
    });

List<Client> getWSClients() {
  if (_wsrouter == null) return [];
  final clientList = _wsrouter.clients;
  final List<Client> retList = []..addAll(clientList)..addAll(_extraClients);
  return retList;
}

void addClient(Client cl) {
  if (!_extraClients.contains(cl)) _extraClients.add(cl);
}

void removeClient(Client cl) {
  if (_extraClients.contains(cl)) _extraClients.remove(cl);
}

void send(String group, String scope, String controller, dynamic value) {
  final wsClients = getWSClients();
  final clients = wsClients.where((client) =>
      permissionCheck(client.req.session, group, scope, $RunRights.read));
  if (clients.isNotEmpty)
    clients.forEach((client) => client.send(controller, value));
}

void sendEvent(String key, [dynamic value]) {
  final parts = key.split(':');
  send(parts[0], parts[1], key, value);
}

Future addNotification(SMessage mes) async {
  await dbWrap<void>((manager) async {
    final not = manager.app.notification.createObject()..key = mes.key;
    if (mes.value != null) not.value = mes.value;
    await manager.app.notification.insert(not);
    mes
      ..notification_id = not.notification_id
      ..date = not.date;
    notificator.add(mes);
  });
}

Future<void> server(String address, int port, [Logger logger]) async {
  final server = await HttpServer.bind(address, port);
  final router = new HttpRouter(server, logger);
  _wsrouter = new WSRouter();
  router.serve(Routes.ws).listen((req) async {
    await _wsrouter.upgrade(req, pingInterval: 55, onDone: () => onclose(req));
  });
  routes.forEach((f) {
    f(router);
    f(_wsrouter);
  });
}

void onServerDown() =>
    addNotification(new SMessage()..key = Routes.eventServerStop);

void onServerStart() =>
    addNotification(new SMessage()..key = Routes.eventServerStart);

void onServerStartUpdate() =>
    addNotification(new SMessage()..key = Routes.eventServerUpdate);

void onServerStartUpdateR() =>
    addNotification(new SMessage()..key = Routes.eventServerUpdater);

void logHandler() {
  final queue = new TaskQueue();
  Logger.root
    ..level = Level.ALL
    ..onRecord.listen((rec) {
      final sb = new StringBuffer()
        ..write('\n[${new DateFormat().add_yMd().add_Hms().format(rec.time)}'
            ' ${rec.level.name}]')
        ..write('\n${rec.message}');
      if (rec.error != null) sb.write('\n${rec.error}');
      String dscr;
      if (rec.stackTrace != null) {
        dscr = Trace.format(rec.stackTrace, terse: true);
        sb.write('\n$dscr');
      }
      // ignore: avoid_print
      if (devmode) print(sb.toString());
      notificator.addLog(LogParser.fillMessageSection(
          new LogMessage()
            ..level = rec.level.name
            ..date = rec.time
            ..title = rec.error.toString()
            ..description = dscr,
          rec.message));
      queue.schedule(() =>
          new File('$path/log/${new DateFormat('y-MM').format(rec.time)}')
              .create(recursive: true)
              .then((file) =>
                  file.writeAsString(sb.toString(), mode: FileMode.append)));
    });
}

class LogParser {
  static RegExp pattern =
      new RegExp(r'\[\d{1,2}/\d{1,2}/\d{4}\s\d{2}:\d{2}:\d{2}\s[A-Z]*\]');

  String filePath;

  LogParser(this.filePath);

  Future<List<LogMessage>> parseFile() async =>
      readContent(await new File(filePath).readAsLines());

  static LogMessage fillMessageSection(LogMessage m, String content) {
    content.split('\n').forEach((line) {
      if (m.type == null && line.startsWith(new RegExp(r'Error|Exception')))
        m.type = line;
      else if (m.title == null && m.type == null)
        m.title = line;
      else if (m.path == null && line.startsWith('/'))
        m.path = line;
      else if (m.session == null && line.startsWith('Session: '))
        m.session = line.replaceAll('Session: ', '');
    });
    return m;
  }

  List<LogMessage> readContent(List<String> lines) {
    final messages = <LogMessage>[];
    LogMessage cur;
    lines.forEach((line) {
      if (line.startsWith(pattern)) {
        final parts = line.replaceAll('[', '').replaceAll(']', '').split(' ');
        cur = new LogMessage()
          ..level = parts.removeLast()
          ..date = DateFormat('MM/dd/yyyy hh:mm:ss').parse(parts.join(' '));
        messages.add(cur);
      } else if (cur != null) {
        if (cur.type == null && line.startsWith(new RegExp(r'Error|Exception')))
          cur.type = line;
        else
          cur.type = cur.level;
        if (cur.type == 'Error' || cur.type == 'Exception') {
          if (cur.path == null && line.startsWith('/'))
            cur.path = line;
          else if (cur.session == null && line.startsWith('Session: '))
            cur.session = line.replaceAll('Session: ', '');
          else if (cur.title == null)
            cur.title = line;
          else
            cur.description =
                '${cur.description != null ? '${cur.description}\n' : ''}$line';
        } else {}
      }
    });
    return messages;
  }
}

enum AppStateStatus { normal, updated, refresh }

Future<AppStateStatus> checkForUpdates() async {
  final prevChecksumFile = new File('$path/tmp/checksum');
  var checkServerFile = new File('$path/bin/out.dart');
  if (!checkServerFile.existsSync())
    checkServerFile = new File('$path/bin/app.dart');
  final checkDirs = [
    new Directory('$path/web'),
    new Directory('$path/web/css')
  ];
  final sb = new StringBuffer();
  final contentServer = await checkServerFile.readAsBytes();
  sb..write(hex.encode(md5.convert(contentServer).bytes))..write('\n');
  for (final d in checkDirs) {
    if (d.existsSync()) {
      final dir = d.list();
      await for (final f in dir) {
        if (f is File) {
          final content = await f.readAsBytes();
          sb..write(hex.encode(md5.convert(content).bytes))..write('\n');
        }
      }
    }
  }
  var changed = AppStateStatus.normal;
  final curChecksum = sb.toString();
  if (prevChecksumFile.existsSync()) {
    final prevChecksum = await prevChecksumFile.readAsString();
    final curParts = curChecksum.split('\n');
    final prevParts = prevChecksum.split('\n');
    final curServerChecksum = curParts.removeAt(0);
    final prevServerChecksum = prevParts.removeAt(0);
    if (prevServerChecksum != curServerChecksum)
      changed = AppStateStatus.updated;
    if (prevParts.join('') != curParts.join(''))
      changed = AppStateStatus.refresh;
  }
  await prevChecksumFile.writeAsString(curChecksum);
  return changed;
}
