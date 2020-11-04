part of gui;

class FormElement extends form.DataElement<Map, DivElement> {
  final form.Form _form;
  form.Form formInner = new form.Form();
  final List<action.Button> _actions = [];

  FormElement([this._form]) {
    dom = new DivElement();
    addClass('form-element');
  }

  void _register(dynamic el) {
    if (el is LabelField) {
      el.elements.forEach(_register);
    } else if (el is form.Data) {
      if (_form != null) _form.add(el);
      formInner.add(el);
    } else if (el is action.Button) {
      _actions.add(el);
    }
  }

  LabelField addRow(dynamic label, List<dynamic> elements) {
    elements.forEach(_register);
    final row = new LabelField(label, elements);
    append(row);
    return row;
  }

  CLElement<HeadingElement> addSection(String title) {
    final h = new CLElement<HeadingElement>(new HeadingElement.h3())
      ..setText(title);
    append(h);
    return h;
  }

  void disable() {
    formInner.disable();
    _actions.forEach((a) => a.disable());
  }

  void enable() {
    formInner.enable();
    _actions.forEach((a) => a.enable());
  }

  E getElement<E extends form.Data>(String name, [String context]) =>
      formInner.getElement<E>(name, context);

  void setValue(Map value) => formInner.setValue(value);

  Map getValue() => formInner.getValue();

  bool isReady() => formInner.isReady();

  Stream<form.Data<Map>> get onValueChanged => formInner.onValueChanged;

  Stream<form.Data<Map>> get onReadyChanged => formInner.onReadyChanged;
}
