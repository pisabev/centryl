part of cl_base.svc.server;

class SNotificator {
  late StreamController<SMessage> _contr;
  late StreamController<History> _contr_request;
  late StreamController<LogMessage> _contr_log;

  late Stream<SMessage> onNotification;
  late Stream<History> onRequest;
  late Stream<LogMessage> onLog;

  SNotificator() {
    _contr = new StreamController.broadcast();
    _contr_request = new StreamController.broadcast();
    _contr_log = new StreamController.broadcast();
    onNotification = _contr.stream;
    onRequest = _contr_request.stream;
    onLog = _contr_log.stream;
  }

  void add(SMessage note) => _contr.add(note);

  void addHistory(History history) => _contr_request.add(history);

  void addLog(LogMessage message) => _contr_log.add(message);
}

class SMessage {
  late int notification_id;
  late DateTime date;
  String key;
  String? value;

  SMessage(this.key);
}

class History {
  String session;
  String controller;
  int? execTime;

  History(this.session, this.controller, [this.execTime]);
}

class LogMessage {
  DateTime? date;
  String? level;
  String? type;
  String? title;
  String? description;
  String? path;
  String? session;
}
