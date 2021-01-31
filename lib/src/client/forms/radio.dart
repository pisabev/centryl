part of forms;

class Radio<T> extends DataElement<T, html.SpanElement> {
  html.RadioButtonInputElement field;

  Radio() : super() {
    dom = new html.SpanElement();
    addClass('ui-field-check');
    field = new html.RadioButtonInputElement();
    append(field);
    append(new html.LabelElement());
    addAction((e) {
      if (!existClass('disabled')) _onClick();
    }, 'click');
    field.onChange.listen((e) {
      contrValue.add(this);
    });
  }

  void setLabel(String lbl) {
    final span = new CLElement(new html.SpanElement())
      ..addClass('label')
      ..addAction(_onClick, 'click')
      ..append(new html.SpanElement()..text = lbl);
    append(span);
  }

  void setName(String name) {
    super.setName(name);
    field.name = name;
  }

  void setValue(T value) {
    super.setValue(value);
    field.value = value.toString();
  }

  void click() => _onClick();

  void _onClick([e]) {
    if (field.disabled) return;
    field.focus();
    setChecked();
  }

  void setChecked() {
    if (!field.checked) contrValue.add(this);
    field.checked = true;
  }

  bool get isChecked => field.checked;

  void focus() => addClass('focus');

  void blur() => removeClass('focus');

  void disable() {
    state = false;
    addClass('disabled');
    field.disabled = true;
  }

  void enable() {
    state = true;
    removeClass('disabled');
    field.disabled = false;
  }
}
