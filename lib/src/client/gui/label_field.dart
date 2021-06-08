part of gui;

class LabelField extends CLElement {
  late dynamic label;
  late List elements;
  CLElement? labelDom;
  late CLElement formData;

  LabelField(this.label, this.elements) : super(new DivElement()) {
    addClass('label-field');
    createDom();
  }

  void setLabel(dynamic label) {
    if (labelDom == null) return;
    labelDom!.removeChilds();
    _appendLabel(label);
  }

  void _appendLabel(dynamic label) {
    if (label is CLElement || label is Element)
      labelDom!.append(label);
    else if (label is String)
      labelDom!.append(new CLElement(new SpanElement())..setText(label));
  }

  void createDom() {
    if (label != null) {
      labelDom = new CLElement(new LabelElement());
      _appendLabel(label);
      append(labelDom);
    }
    formData = new CLElement(new DivElement())..addClass('form-data');
    elements.forEach((e) {
      if (e is String)
        new CLElement(new SpanElement())
          ..setText(e)
          ..appendTo(formData);
      else if (e is CLElementBase) {
        if (e is form.DataElement && e is! form.Check && e is! form.Radio)
          e.addClass('max');
        e.appendTo(formData);
      }
    });
    append(formData);
  }
}
