part of base;

class LoadElement extends CLElement {
  CLElementBase container;
  Timer? _sub;

  LoadElement(this.container, [int delay = 100]) : super(new DivElement()) {
    if (container.dom.attributes['loading'] != null) return;
    container
      ..setStyle({'position': 'relative'})
      ..setAttribute('loading', 'true');
    setClass('ui-loader');
    appendTo(container);
    new CLElement(new SpanElement())
      ..appendTo(this)
      ..setClass('loader');
    _sub =
        new Timer(new Duration(milliseconds: delay), () => addClass('active'));
  }

  void remove() {
    _sub?.cancel();
    super.remove();
    container.dom.attributes.remove('loading');
  }
}
