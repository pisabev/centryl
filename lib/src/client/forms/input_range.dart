part of forms;

class InputRange<T extends num> extends DataElement<T, html.SpanElement> {
  num min;
  num max;
  num step;
  CLElement domInfo;
  CLElement domInfoLeft;
  CLElement domInfoRight;
  CLElement domLabel;
  CLElement domTrack;
  CLElement domProgress;
  CLElement domThumb;

  num dif, pos;
  html.Rectangle rect;

  InputRange({this.min = 0, this.max = 100, this.step = 1})
      : super() {
    dom = new html.SpanElement();
    domInfo = new CLElement(new html.SpanElement())
      ..addClass('ui-info')
      ..appendTo(this);
    domInfoLeft = new CLElement(new html.SpanElement())
      ..addClass('ui-min')
      ..setText(min.toString())
      ..appendTo(domInfo);
    domInfoRight = new CLElement(new html.SpanElement())
      ..addClass('ui-max')
      ..setText(max.toString())
      ..appendTo(domInfo);
    domTrack = new CLElement(new html.SpanElement())
      ..addClass('ui-track')
      ..appendTo(this);
    domProgress = new CLElement(new html.SpanElement())
      ..addClass('ui-progress')
      ..appendTo(domTrack);
    domThumb = new CLElement(new html.SpanElement())
      ..addClass('ui-thumb')
      ..appendTo(domProgress);
    domLabel = new CLElement(new html.SpanElement())
      ..addClass('ui-label')
      ..appendTo(domThumb);
    addClass('ui-field-range');

    domThumb.dom
      ..draggable = true
      ..onDragStart.listen(dragStart)
      ..onDrag.listen(doDrag)
      ..onDragEnd.listen(dragEnd);
  }

  void dragStart(html.MouseEvent ev) {
    rect = domProgress.dom.getBoundingClientRect();
    final x = ev.client.x;
    dif = ((x-rect.left)/(rect.width) * (max-min))/2 - getValue();
  }

  void doDrag(html.MouseEvent ev) {
    final x = ev.client.x;
    pos = ((x-rect.left)/rect.width * (max-min))/2 -dif;

    pos = (pos ~/ step)*step;
    if (pos < min) pos = min;
    if (pos > max) pos = max;
    domLabel.setText(pos.toStringAsFixed(0));
  }

  void dragEnd(html.MouseEvent ev) {
    final x = ev.client.x;
    pos = ((x-rect.left)/rect.width * (max-min))/2 -dif;

    pos = (pos ~/ step)*step;
    if (pos < min) pos = min;
    if (pos > max) pos = max;
    setValue(pos as T);
  }

  @override
  void setValue(T value) => setValueDynamic(value);
  @override
  T getValue() => getValueDynamic();

  void setValueDynamic(T value) {
    final val = ((value - min)/(max-min))*100;
    domLabel.setText(value.toStringAsFixed(0));
    domProgress.setStyle({'width': '$val%'});
  }

  T getValueDynamic() {
    var txt = domProgress.dom.style.width;
    if (txt == null || txt.isEmpty) return 0 as T;
    txt = txt.substring(0, txt.length-1);
    final val = num.tryParse(txt);
    final value = (val/100)*(max-min) + min;
    return value as T;
  }

}
