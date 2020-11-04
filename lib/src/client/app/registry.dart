part of app;

class Registry {
  final Map<String, Route> _actions = {};

  final Map<String, Item> _cache = {};

  void addRoute(Route route) {
    _actions[route.getRoute()] = route;
  }

  Route getRoute(String key) {
    final keyPattern = _actions.keys
        .firstWhere((k) => Route.match(new RegExp(k), key), orElse: () => null);
    if (keyPattern == null) return null;
    return _actions[keyPattern];
  }

  void add(String key, Item value) {
    _cache[key] = value;
  }

  Item get(String key) => _cache[key];

  void remove(Object value) {
    String key;
    _cache.forEach((k, v) {
      if (v == value) key = k;
    });
    if (key != null) _cache.remove(key);
  }
}
