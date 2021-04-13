part of app;

class NotificationMessage {
  static const String warning = 'warning';
  static const String info = 'info';
  static const String error = 'error';
  static const String attention = 'attention';

  static final Map<String, Function(NotificationMessage)> _decorator = {};

  int? id;
  bool persist = true;
  String? event;
  String? text;
  String? icon;
  DateTime? date;
  late bool read;
  late String priority;
  Function? action;
  Function(forms.Text)? textFunction;

  NotificationMessage([this.priority = info]);

  factory NotificationMessage.fromMap(Map n) {
    final not = new NotificationMessage()
      ..event = n['event']
      ..text = n['text']
      ..id = n['id']
      ..icon = n['icon']
      ..read = n['read'] ?? false
      ..priority = n['priority'] ?? info
      ..date = utils.Calendar.parseWithTimeFull(n['date'])?.toLocal();
    if (_decorator[not.event] != null) _decorator[not.event]!(not);
    return not;
  }

  static void registerDecorator(
      String event, Function(NotificationMessage) func) {
    _decorator[event] = func;
  }

  static void removeDecorator(String event) => _decorator.remove(event);
}
