part of utils;

typedef ObserverFunction<T> = FutureOr<bool> Function(T);

class Observer {
  final Map<String, Queue> _hook = {};

  Observer();

  void addHook<T>(String scope, ObserverFunction<T> func,
      [bool first = false]) {
    if (_hook[scope] == null) _hook[scope] = new Queue();
    if (func is Function) {
      if (first)
        _hook[scope]!.addFirst(func);
      else
        _hook[scope]!.add(func);
    }
  }

  Queue? getHook(String scope) => _hook[scope];

  Future<bool> execHooksAsync(String scope, [dynamic object]) {
    final completer = new Completer<bool>();
    if (_hook[scope] is Queue) {
      final iterator = _hook[scope]!.iterator;
      var ret = true;
      Future.doWhile(() async {
        if (!iterator.moveNext()) return false;
        return ret = await iterator.current(object);
      })
          .then((_) => completer.complete(ret))
          .catchError(completer.completeError);
    } else {
      completer.complete(true);
    }
    return completer.future;
  }

  bool execHooks(String scope, [dynamic object]) {
    if (_hook[scope] is Queue) {
      final iterator = _hook[scope]!.iterator;
      var ret = true;
      while (iterator.moveNext()) {
        final r = iterator.current(object);
        if (r == false) {
          ret = false;
          break;
        }
      }
      return ret;
    } else {
      return true;
    }
  }

  void removeHook<T>(String scope, [ObserverFunction<T>? func]) {
    if (func is Function) {
      if (_hook[scope] != null && _hook[scope]!.contains(func))
        _hook[scope]!.remove(func);
    } else {
      _hook[scope] = new Queue();
    }
  }
}
