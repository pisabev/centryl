part of utils;

class Drag {
  CLElement object;
  CLElement context;

  Rectangle _init_rect;
  math.MutableRectangle rect;
  Rectangle _bound_rect;
  CLElement bound;
  Function _start = (_) {};
  Function _on = (_) {};
  Function _end = (_) {};

  MouseEvent _init_e;

  num dx = 0;
  num dy = 0;

  bool enable = true;

  Drag(this.object, {namespace = 'drag', int delay = 200}) {
    object.addAction((e) {
      final timer = new Timer(new Duration(milliseconds: delay), () => drag(e));
      StreamSubscription document_up;
      document_up = document.onMouseUp.listen((e) {
        timer.cancel();
        document_up.cancel();
      });
    }, 'mousedown.$namespace');
  }

  void start(FutureOr Function(MouseEvent) start) => _start = start;

  void on(FutureOr Function(MouseEvent) on) => _on = on;

  void end(FutureOr Function(MouseEvent) stop) => _end = stop;

  void drag(MouseEvent e) {
    if (!enable) return;
    context ??= object;
    _init_e = e;
    _init_rect = context.dom.offset;
    rect = new math.MutableRectangle(
        _init_rect.left, _init_rect.top, _init_rect.width, _init_rect.height);
    if (bound != null) {
      final pos = bound.getStyle('position');
      _bound_rect = bound.dom.offset;
      if (pos == 'absolute' || pos == 'relative' || pos == 'fixed')
        _bound_rect = new math.MutableRectangle(
            0, 0, _bound_rect.width, _bound_rect.height);
    }
    _start(e);
    final document_move = document.onMouseMove.listen((e) {
      document.body.classes.add('dragging');
      dx = e.page.x - _init_e.page.x;
      dy = e.page.y - _init_e.page.y;
      rect
        ..left = _init_rect.left + dx
        ..top = _init_rect.top + dy;
      if (_bound_rect != null) rect = boundRect(rect, _bound_rect);
      _on(e);
    });
    StreamSubscription document_up;
    document_up = document.onMouseUp.listen((e) {
      document.body.classes.remove('dragging');
      document_move.cancel();
      document_up.cancel();
      _end(e);
    });
  }
}
