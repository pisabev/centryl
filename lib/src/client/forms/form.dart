part of forms;

class Form<T extends Data> extends Data<Map> {
  bool isLoading = false;
  final List<Data> _loadingQueue = [];
  final StreamController _contrLoadStart = new StreamController.broadcast();
  final StreamController _contrLoadEnd = new StreamController.broadcast();

  Stream get onLoadStart => _contrLoadStart.stream;

  Stream get onLoadEnd => _contrLoadEnd.stream;

  Map<String, bool Function()> validationRules = {};

  final List<T> indexOfElements = [];

  void add(dynamic el) {
    el.onValueChanged.listen((_) => contrValue.add(this));
    el.onReadyChanged.listen((_) => contrReady.add(this));
    el.onWarning.listen((_) => contrWarning.add(this));
    void _addToQueue(Data el) {
      if (!_loadingQueue.contains(el))
        _loadingQueue.add(el);
      else
        throw new Exception(
            'Form\'s LoadingQueue error - addToQueue: ${el.getName()}');
    }

    void _removeFromQueue(Data el) {
      if (_loadingQueue.contains(el))
        _loadingQueue.remove(el);
      else
        throw new Exception(
            'Form\'s loadingQueue error - removeFromQueue: ${el.getName()}');
    }

    if (el is DataLoader || el is Form) {
      if (el.isLoading) {
        if (!isLoading) _contrLoadStart.add(this);
        isLoading = true;
        _addToQueue(el);
      }
      el.onLoadStart.listen((e) {
        if (!isLoading) _contrLoadStart.add(this);
        isLoading = true;
        _addToQueue(el);
      });
      el.onLoadEnd.listen((_) async {
        _removeFromQueue(el);
        if (_loadingQueue.isEmpty) {
          isLoading = false;
          _contrLoadEnd.add(this);
        }
      });
    }
    indexOfElements.add(el);
  }

  T remove(String name) {
    Data el;
    indexOfElements.removeWhere((e) {
      if (e.getName() == name) {
        el = e;
        _loadingQueue.remove(e);
        return true;
      }
      return false;
    });
    return el;
  }

  void removeAll() =>
      indexOfElements.toList()..forEach((el) => remove(el.getName()));

  Map<String, dynamic> getValue() {
    if (!_send) return null;
    final o = <String, dynamic>{};
    for (var i = 0; i < indexOfElements.length; i++) {
      final el = indexOfElements[i];
      if (!el._send) continue;
      final key = el.getName(), value = el.getValue();
      if (key == null) continue;
      final context = el.getContext();
      if (context != null) {
        if (o[context] == null) o[context] = <String, dynamic>{};
        o[context][key] = value;
      } else
        o[key] = value;
    }
    return o;
  }

  List<T> getNotReady() =>
      indexOfElements.where((el) => !el.isReady()).toList();

  List<DataWarning> getWarnings() {
    final w = <DataWarning>[];
    indexOfElements.forEach((el) {
      if (el.hasWarnings()) w.addAll(el.getWarnings());
    });
    w.addAll(super.getWarnings());
    return w;
  }

  void removeWarning(String wrnKey) {
    super.removeWarning(wrnKey);
    indexOfElements.forEach((el) => el.removeWarning(wrnKey));
  }

  void removeWarnings() {
    super.removeWarnings();
    indexOfElements.forEach((el) => el.removeWarnings());
  }

  bool isReady() =>
      super.isReady() &&
      indexOfElements.every((el) => el.isReady()) &&
      validationRules.keys.every((k) => validationRules[k]());

  List<E> getElementsByContext<E extends T>(String context) =>
      indexOfElements.where((el) => el.getContext() == context).toList();

  E getElement<E extends T>(String name, [String context]) =>
      indexOfElements.firstWhere(
          (el) => el.getName() == name && el.getContext() == context,
          orElse: () => null);

  void setState(bool state) =>
      indexOfElements.forEach((el) => el.setState(state));

  void disable() => indexOfElements.forEach((el) => el.disable());

  void enable() => indexOfElements.forEach((el) => el.enable());

  void setValue(Map value) {
    if (value == null) {
      clear();
      return;
    }
    void _setByContext(String k, Map v) {
      final els = getElementsByContext(k);
      v.forEach((k1, v1) {
        final el =
            els.firstWhere((el) => el.getName() == k1, orElse: () => null);
        if (el != null) el.setValue(v1);
      });
    }

    value.forEach((k, v) {
      final el = getElement(k);
      if (v is Map) {
        if (el != null) {
          el.setValue(v);
        } else {
          _setByContext(k, v);
        }
      } else if (el != null) {
        el.setValue(v);
      }
    });
  }

  void clear() {
    indexOfElements.forEach((el) => el.setValue(null));
  }
}
