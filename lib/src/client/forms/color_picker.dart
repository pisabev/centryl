part of forms;

/*class ColorPicker extends DataElement<String, html.DivElement> {
  StreamController _contrOpen = new StreamController.broadcast();
  StreamController _contrClose = new StreamController.broadcast();

  Stream<Null> get onPickerOpen => _contrOpen.stream;
  Stream<Null> get onPickerClose => _contrClose.stream;

  final CP.ColorPicker picker = new CP.ColorPicker();
  utils.UISlider _slider;
  CLElement _inner;

  ColorPicker() : super() {
    dom = new html.DivElement();
    setClass('ui-field-color-picker');

    _inner = new CLElement(new html.DivElement());

    var outer = new CLElement(new html.DivElement())
      ..setClass('outer')
      ..append(_inner)
      ..appendTo(this);

    picker.onColorChange((c) {
      var s = c.toHexColor().toCssString();
      super.setValue(s);
      _inner.dom.style.backgroundColor = s;
    });

    var wrap = new CLElement(new html.DivElement())..append(picker.element);

    _slider = new utils.UISlider(wrap, this)..autoWidth = false;
    outer.addAction(showColorPicker);
  }

  void setValue(String value) {
    if (value != null && value.length == 7) {
      picker.color = new color.HexColor(value);
      _inner.dom.style.backgroundColor = value;
      super.setValue(value);
    } else {
      picker.color = new color.RgbColor(255, 255, 255);
      _inner.dom.style.backgroundColor = '#ffffff';
      super.setValue(null);
    }
  }

  void focus();

  void blur();

  void disable();

  void enable();

  void fieldUpdate(value) {
    setValue(value);
    hideColorPicker();
  }

  void hideColorPicker() {
    _slider.hide();
    _contrClose.add(null);
  }

  void showColorPicker(e) {
    CLElement doc;
    doc = new CLElement(html.document.body)
      ..addAction((e) {
        hideColorPicker();
        doc.removeAction('mousedown.date');
      }, 'mousedown.date');

    _slider.show();
    _contrOpen.add(null);
    picker.color = picker
        .color; //getBoundingClientRect does not work with display=none; Refresh pointer positions
  }
}
*/