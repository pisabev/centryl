part of forms;

class Check<T> extends DataElement<T, html.SpanElement> {
  final String _type;
  html.LabelElement label;
  CLElement textLabel;
  html.CheckboxInputElement field;

  Check([this._type = 'int']) : super() {
    dom = new html.SpanElement();
    addClass('ui-field-check');
    field = new html.CheckboxInputElement();
    label = new html.LabelElement();
    append(field);
    append(label);
    new CLElement(label).addAction(onClick, 'click');
    field.onChange.listen((e) {
      contrValue.add(this);
    });
  }

  void setLabel(String lbl) {
    if (textLabel == null) {
      textLabel = new CLElement(new html.SpanElement())
        ..addClass('label')
        ..addAction(onClick, 'click');
      append(textLabel);
    }
    textLabel
      ..removeChilds()
      ..append(new html.SpanElement()..text = lbl);
  }

  void onClick(_) {
    field.focus();
    if (!field.disabled)
      setValue(getValueInverse());
  }

  void setChecked(bool checked) => field.checked = checked;

  bool isChecked() => field.checked;

  void toggle() => field.checked = !field.checked;

  void setValue(dynamic value) {
    final old = getValue();
    if (value is num)
      field.checked = value != 0;
    else if (value is bool)
      field.checked = value;
    else
      field.checked = false;
    if (getValue() != old) contrValue.add(this);
  }

  int _getIntValue() => (field.checked) ? 1 : 0;

  bool _getBoolValue() => field.checked;

  T getValue() => _type == 'int' ? _getIntValue() : _getBoolValue();

  T getValueInverse() =>
      _type == 'int' ? (_getIntValue() == 1 ? 0 : 1) : !_getBoolValue();

  void focus() {}

  void blur() {}

  void disable() {
    state = false;
    addClass('disabled');
    setAttribute('tabindex', '-1');
    field.disabled = true;
  }

  void enable() {
    state = true;
    removeClass('disabled');
    setAttribute('tabindex', '0');
    field.disabled = false;
  }

  void click() => field.click();
}
