part of gui;

class Pop extends CLElement {
  late CLElement doc;
  late num width;
  num height = 0;
  late Rectangle view;

  Pop(CLElement content, e) : super(new DivElement()) {
    setClass('ui-popUp');
    doc = new CLElement(document.body);
    view = doc.getRectangle();
    doc.addAction(clickPosition, 'mousedown.pop');
    set(content, e);
  }

  void set(CLElement content, Event e) {
    append(content);
    appendTo(doc);
    width = getWidth();
    height = getHeight();
    final pos = getFixedPosition(e as MouseEvent);
    setStyle({'top': '${pos.top}px', 'left': '${pos.left}px'});
    addClass('ui-popUp-active');
  }

  Rectangle getFixedPosition(MouseEvent e) {
    final pos = new math.MutableRectangle(0, 0, 0, 0)
      ..left = e.page.x as int
      ..top = e.page.y as int;
    final left_strech = pos.left + width,
        top_strech = pos.top + height,
        diff_hor = left_strech - view.width,
        diff_ver = top_strech - view.height;
    pos
      ..left -= (diff_hor as int > 0) ? diff_hor : 0
      ..top -= (diff_ver as int > 0) ? diff_ver : 0;
    return pos;
  }

  void clickPosition(MouseEvent e) {
    final rect = getRectangle();
    if (((rect.top < e.page.y) && (e.page.y < (rect.top + rect.height))) &&
        ((rect.left < e.page.x) && (e.page.x < (rect.left + rect.width)))) {
      return;
    }
    close();
  }

  void close() {
    doc.removeAction('mousedown.pop');
    remove();
  }
}
