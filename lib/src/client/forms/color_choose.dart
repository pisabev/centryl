part of forms;

class ColorChoose extends DataElement<int, html.DivElement> {
  List colors;

  ColorChoose() : super() {
    dom = new html.DivElement();
    setClass('ui-field-color-choose');
    for (var i = 0; i < 6; i++) {
      new CLElement(new html.DivElement())
        ..setClass('outer')
        ..append(
            new CLElement(new html.DivElement())..setClass('color${i + 1}'))
        ..appendTo(this)
        ..addAction((e) => setValue(i + 1));
    }
  }

  void _click(int num) {
    dom.children.forEach((el) {
      new CLElement(el).removeClass('selected');
    });
    if (num != null && dom.children.length >= num)
      new CLElement(dom.children[num - 1]).addClass('selected');
  }

  void setValue(int value) {
    super.setValue(value);
    _click(value);
  }

  void focus() {}

  void blur() {}

  void disable() {}

  void enable() {}
}
