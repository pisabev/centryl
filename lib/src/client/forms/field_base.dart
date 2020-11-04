part of forms;

abstract class FieldBase<T, E extends html.Element> extends DataElement<T, E>
    with Validator {
  html.SpanElement inner, input;
  CLElement<html.Element> field;
  List<CLElementBase> _suffix = [];
  List<CLElementBase> _prefix = [];

  FieldBase() {
    onReadyChanged.listen((e) {
      if (e.isReady())
        removeClass('error');
      else
        addClass('error');
    });
  }

  void _onFocus(html.Event e) {
    addClass('focus');
  }

  void setValue(T value);

  void setValueDynamic(dynamic value);

  void focus() {
    field.dom.focus();
  }

  void blur() {
    field.dom.blur();
  }

  void setPlaceHolder(String value);

  void select();

  void disable() {
    state = false;
    addClass('disabled');
    field.setAttribute('tabindex', '-1');
    field.dom.setAttribute('disabled', 'true');
  }

  void enable() {
    state = true;
    removeClass('disabled');
    field.setAttribute('tabindex', '0');
    field.dom.attributes.remove('disabled');
  }

  void setSuffix(String str, [bool append = false]) {
    if (!append) {
      _suffix.forEach((e) => e.remove());
      _suffix = [];
    }
    final suffix = new CLElement(new html.SpanElement())
      ..addClass('text')
      ..addClass('suffix')
      ..append(new html.SpanElement()..text = str);
    _suffix.add(suffix);
    inner.append(suffix.dom);
  }

  void setPrefix(String str, [bool append = false]) {
    if (!append) {
      _prefix.forEach((e) => e.remove());
      _prefix = [];
    }
    final prefix = new CLElement(new html.SpanElement())
      ..addClass('text')
      ..addClass('prefix')
      ..append(new html.SpanElement()..text = str);
    _prefix.add(prefix);
    inner.insertBefore(prefix.dom, input);
  }

  void setSuffixElement(CLElementBase el, [bool append = false]) {
    if (!append) {
      _suffix.forEach((e) => e.remove());
      _suffix = [];
    }
    el.addClass('suffix');
    _suffix.add(el);
    inner.append(el.dom);
  }

  void setPrefixElement(CLElementBase el, [bool append = false]) {
    if (!append) {
      _prefix.forEach((e) => e.remove());
      _prefix = [];
    }
    el.addClass('prefix');
    _prefix.add(el);
    inner.insertBefore(el.dom, input);
  }
}
