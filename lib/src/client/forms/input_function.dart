part of forms;

class InputFunction<T> extends InputField<T> {
  String icon = Icon.search;
  late CLElement domAction;
  bool full = false;

  InputFunction() : super() {
    domAction = new CLElement(new Icon(icon).dom)
      ..addClass('suffix')
      ..addClass('clickable')
      ..appendTo(inner);
    addAction((e) {
      domAction.dom.click();
    }, 'dblclick');
  }

  @override
  void setValue(dynamic value) {
    final v = value ?? [null, null];
    super.setValue(v[0]);
    setValueDynamic(v[1]);
  }

  void setValueDynamic(dynamic value) {
    field.dom.value = (value == null) ? '' : value.toString();
  }

  String getText() => field.dom.value!;

  @override
  void disable() {
    super.disable();
    domAction.setState(false);
  }

  @override
  void enable() {
    super.enable();
    domAction.setState(true);
  }

  @override
  void addAction<E extends html.Event>(EventFunction<E> func,
      [String event_space = 'click']) {
    field.addAction(func, event_space);
  }
}
