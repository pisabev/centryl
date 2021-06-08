part of app;

class MessageBus {
  static final Map<String, MessageBusSub> _m = {};

  late Stream main_stream;

  StreamController contr = new StreamController();

  MessageBus();

  void _hook(Stream<List> stream) {
    main_stream = stream
      ..listen((d) {
        if (_m.containsKey(d[0])) _m[d[0]]!._add(d[1]);
        contr.add(d[1]);
      });
  }

  bool removeFilter(String filter) {
    if (!_m.containsKey(filter)) return false;
    _m.remove(filter);
    return true;
  }

  MessageBusSub filter(String filter) =>
      (_m.containsKey(filter)) ? _m[filter]! : _m[filter] = new MessageBusSub();

  StreamSubscription listen(void Function(dynamic) onData) =>
      main_stream.listen(onData);
}

class MessageBusSub {
  StreamController contr = new StreamController.broadcast();

  void _add(data) => contr.add(data);

  StreamSubscription listen(void Function(dynamic) onData) =>
      contr.stream.listen(onData);
}
