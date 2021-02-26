part of forms;

class ElementTrack<T extends Data> {
  final T element;
  StreamSubscription valueChange;
  StreamSubscription readyChange;
  StreamSubscription warning;
  bool inLoadingQueue = false;

  ElementTrack(this.element);

  void destroy() {
    valueChange.cancel();
    readyChange.cancel();
    warning.cancel();
  }
}

class Form<T extends Data> extends Data<Map> {
  bool isLoading = false;
  final StreamController _contrLoadStart = new StreamController.broadcast();
  final StreamController _contrLoadEnd = new StreamController.broadcast();

  Stream get onLoadStart => _contrLoadStart.stream;

  Stream get onLoadEnd => _contrLoadEnd.stream;

  Map<String, bool Function()> validationRules = {};

  final List<ElementTrack<T>> _indexOfElements = [];

  void add(dynamic el) {
    final track = new ElementTrack<T>(el)
      ..valueChange = el.onValueChanged.listen((_) => contrValue.add(this))
      ..readyChange = el.onReadyChanged.listen((_) => contrReady.add(this))
      ..warning = el.onWarning.listen((_) => contrWarning.add(this));
    _indexOfElements.add(track);

    void _addToQueue(Data el) {
      final found = _indexOfElements.firstWhere((e) => e.element == el);
      if (!found.inLoadingQueue)
        found.inLoadingQueue = true;
      else
        throw new Exception(
            'Form\'s LoadingQueue error - addToQueue: ${el.getName()}');
    }

    void _removeFromQueue(Data el) {
      final found = _indexOfElements.firstWhere((e) => e.element == el);
      if (found.inLoadingQueue)
        found.inLoadingQueue = false;
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
        if (_indexOfElements.every((e) => !e.inLoadingQueue)) {
          isLoading = false;
          _contrLoadEnd.add(this);
        }
      });
    }
  }

  T remove(String name) {
    Data el;
    _indexOfElements.removeWhere((e) {
      if (e.element.getName() == name) {
        el = e.element;
        e.destroy();
        return true;
      }
      return false;
    });
    return el;
  }

  void removeAll() =>
      _indexOfElements.toList().forEach((el) => remove(el.element.getName()));

  Map<String, dynamic> getValue() {
    if (!_send) return null;
    final o = <String, dynamic>{};
    for (var i = 0; i < _indexOfElements.length; i++) {
      final el = _indexOfElements[i];
      if (!el.element._send) continue;
      final key = el.element.getName(), value = el.element.getValue();
      if (key == null) continue;
      final context = el.element.getContext();
      if (context != null) {
        if (o[context] == null) o[context] = <String, dynamic>{};
        o[context][key] = value;
      } else
        o[key] = value;
    }
    return o;
  }

  List<T> getNotReady() => _indexOfElements
      .where((el) => !el.element.isReady())
      .map((e) => e.element)
      .toList();

  List<DataWarning> getWarnings() {
    final w = <DataWarning>[];
    _indexOfElements.forEach((el) {
      if (el.element.hasWarnings()) w.addAll(el.element.getWarnings());
    });
    w.addAll(super.getWarnings());
    return w;
  }

  void removeWarning(String wrnKey) {
    super.removeWarning(wrnKey);
    _indexOfElements.forEach((el) => el.element.removeWarning(wrnKey));
  }

  void removeWarnings() {
    super.removeWarnings();
    _indexOfElements.forEach((el) => el.element.removeWarnings());
  }

  bool isReady() =>
      super.isReady() &&
      _indexOfElements.every((el) => el.element.isReady()) &&
      validationRules.keys.every((k) => validationRules[k]());

  List<E> getElementsByContext<E extends T>(String context) => _indexOfElements
      .where((el) => el.element.getContext() == context)
      .map((e) => e.element)
      .toList();

  E getElement<E extends T>(String name, [String context]) => _indexOfElements
      .firstWhere(
          (el) =>
              el.element.getName() == name &&
              el.element.getContext() == context,
          orElse: () => null)
      ?.element;

  void setState(bool state) =>
      _indexOfElements.forEach((el) => el.element.setState(state));

  void disable() => _indexOfElements.forEach((el) => el.element.disable());

  void enable() => _indexOfElements.forEach((el) => el.element.enable());

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

  void forEach(void Function(T e) com) =>
      _indexOfElements.forEach((element) => com(element.element));

  List<T> get elements => _indexOfElements.map((e) => e.element).toList();

  void clear() => _indexOfElements.forEach((el) => el.element.setValue(null));
}
