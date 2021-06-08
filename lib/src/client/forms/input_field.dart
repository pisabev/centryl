part of forms;

abstract class InputField<T> extends FieldBase<T, html.SpanElement>
    with Validator {
  covariant late CLElement<html.InputElement> field;
  late action.Warning warning;

  InputField([InputType? type]) {
    if (type != null) set(type);
    dom = new html.SpanElement();
    addClass('ui-field-input');
    inner = new html.SpanElement()..classes.add('inner');
    input = new html.SpanElement()..classes.add('input');
    field = new CLElement(new html.InputElement());
    input.append(field.dom);
    inner.append(input);
    input.append(new html.SpanElement()..classes.add('separator'));
    append(inner);

    warning = new action.Warning(new CLElement(input));

    field
      ..addAction(_onFocus, 'focus')
      ..addAction(_onBlur, 'blur')
      ..addAction(_onKeyDown, 'keydown')
      ..addAction<html.Event>((e) {
        if (!validateInput(e)) e.preventDefault();
      }, 'keypress');
  }

  void _onBlur(html.Event e) {
    removeClass('focus');
    final value = getValue();
    final string_value = value == null ? '' : value.toString();
    if (string_value != field.dom.value)
      setValueDynamic(field.dom.value!.isEmpty ? null : field.dom.value);
  }

  void _onKeyDown(html.KeyboardEvent e) {
    if (e.keyCode == 13)
      setValueDynamic(field.dom.value!.isEmpty ? null : field.dom.value);
  }

  void setPlaceHolder(String value) {
    field.dom.placeholder = value;
  }

  void setWarning(DataWarning? wrn, {bool show = true}) {
    if (wrn == null) return;
    super.setWarning(wrn);
    warning.init(getWarnings(), showAuto: show);
  }

  void showWarnings([Duration? duration]) {
    warning.show(duration);
  }

  void removeWarning(String? wrnKey) {
    if (wrnKey == null) return;
    super.removeWarning(wrnKey);
    warning.remove();
  }

  void removeWarnings() {
    super.removeWarnings();
    warning.remove();
  }

  void select() {
    field.dom.select();
  }

  void addAction<E extends html.Event>(EventFunction<E> func,
      [String event_space = 'click']) {
    field.addAction(func, event_space);
  }
}
