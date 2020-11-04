part of forms;

class Data<T> {
  final StreamController<Data<T>> contrValue = new StreamController.broadcast();
  final StreamController<Data<T>> contrWarning =
      new StreamController.broadcast();
  final StreamController<Data<T>> contrReady = new StreamController.broadcast();

  Stream<Data<T>> get onValueChanged => contrValue.stream;

  Stream<Data<T>> get onWarning => contrWarning.stream;

  Stream<Data<T>> get onReadyChanged => contrReady.stream;

  bool _send = true;
  bool _required = false;
  bool _valid = true;
  List<DataWarning> _warnings = [];
  String _context;
  String _name;
  T _value;

  void stop() {
    _send = false;
  }

  void setName(String name) {
    _name = name;
  }

  String getName() => _name;

  void setContext(String context) {
    _context = context;
  }

  String getContext() => _context;

  bool compareValue(T value) => _value != value;

  void setValue(T value) {
    final changed = compareValue(value);
    _value = value;
    if (_send && changed) {
      contrValue.add(this);
      contrReady.add(this);
    }
  }

  T getValue() => _value;

  void setRequired(bool required) {
    final changed = _required != required;
    _required = required;
    if (changed) contrReady.add(this);
  }

  bool isRequired() => _required;

  bool isValid() => _valid;

  bool isReady() => !(_required && !hasValue()) && _valid;

  bool hasValue() => getValue() != null;

  void setValid(bool v) {
    final changed = _valid != v;
    _valid = v;
    if (changed) contrReady.add(this);
  }

  void setWarning(DataWarning wrn) {
    if (_warnings.any((w) => w.key == wrn.key)) return;
    _warnings.add(wrn);
    contrWarning.add(this);
  }

  void removeWarning(String wrnKey) {
    if (_warnings.every((w) => w.key != wrnKey)) return;
    _warnings.removeWhere((wrn) => wrn.key == wrnKey);
    contrWarning.add(this);
  }

  void removeWarnings() {
    if (_warnings.isEmpty) return;
    _warnings = [];
    contrWarning.add(this);
  }

  bool hasWarnings() => _warnings.isNotEmpty;

  List<DataWarning> getWarnings() => _warnings;

  FutureOr<String> getRepresentation() => '${_value ?? ''}';

  FutureOr<html.Element> getRepresentationElement() => null;

  void blur() {}

  void focus() {}

  void select() {}

  void disable() {}

  void enable() {}

  void setState(bool state) {
    if (state)
      enable();
    else
      disable();
  }
}
