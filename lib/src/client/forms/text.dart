part of forms;

class Text<T, E extends html.Element> extends DataElement<T, E> {
  final bool text;

  Text({html.Element? el, this.text = true}) : super() {
    dom = (el ?? new html.SpanElement()) as E;
  }

  void setValue(T? value) {
    super.setValue(value);
    if (text)
      dom.text = value == null ? '' : value.toString();
    else
      dom.setInnerHtml(value == null ? '' : value.toString());
  }

  void focus() {}

  void blur() {}

  void disable() {}

  void enable() {}
}
