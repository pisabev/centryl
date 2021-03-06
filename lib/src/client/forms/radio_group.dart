part of forms;

class RadioGroup<T> extends Data<T> {
  static int _counter = 0;
  List<Radio<T>> elements = [];

  RadioGroup(String name) {
    _counter++;
    setName(name);
  }

  void registerElement(Radio<T> r) {
    r
      ..setName('${getName()}|$_counter')
      ..stop();
    r.onValueChanged.listen((e) => contrValue.add(this));
    elements.add(r);
  }

  void setValue(T? value) {
    if (value == null) {
      final oldValue = getValue();
      elements.forEach((el) => el.field.checked = false);
      if (getValue() != oldValue) contrValue.add(this);
      return;
    }
    final v = elements.firstWhereOrNull((e) => e.getValue() == value);
    v?.setChecked();
  }

  T? getValue() {
    final v = elements.firstWhereOrNull((e) => e.field.checked!);
    return v?.getValue();
  }

  void disable() => elements.forEach((e) => e.disable());

  void enable() => elements.forEach((e) => e.enable());

  void show() => elements.forEach((e) => e.show());

  void hide() => elements.forEach((e) => e.hide());
}
