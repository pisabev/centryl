part of forms;

class Tag extends DataElement<List, html.DivElement> {
  List<Form> forms = [];

  Tag() : super() {
    dom = new html.DivElement();
    setClass('ui-tag');
  }

  void addValue(List value) {
    final form = new Form()
      ..add(new Data()
        ..setName('value')
        ..setValue(value[0]));
    forms.add(form);
    final tag = new CLElement(new html.SpanElement())
      ..setClass('ui-field-tag')
      ..appendTo(this);
    new CLElement(new html.SpanElement())
      ..setClass('ui-field-tag-inner')
      ..setText(value[1])
      ..appendTo(tag);
    new CLElement(new html.AnchorElement())
      ..append(new Icon(Icon.clear).dom)
      ..addAction((e) => _remove(form, tag))
      ..appendTo(tag);
  }

  void setValue(List? value) {
    for (var i = 0; i < forms.length; i++) {
      final val = forms[i].getElement('value');
      if (val != null && value != null && val == value[0]) return;
    }
    if (value != null) addValue(value);
  }

  List<Map> getValue() {
    final a = <Map>[];
    forms.forEach((f) => a.add(f.getValue()));
    return a;
  }

  void _remove(form, tag) {
    forms.remove(form);
    tag.remove();
  }

  void focus() {}

  void blur() {}

  void disable() {}

  void enable() {}
}
