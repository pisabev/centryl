part of base;

class Container<E extends Element> extends CLElement<E> {
  bool _auto = false;
  CLscroll scroll;
  Container parent;
  List<Container> containers = [];

  Container([element]) : super(element ?? new DivElement()) {
    addClass('ui-container');
  }

  set auto(bool a) {
    _auto = a;
    if (_auto)
      addClass('ui-auto');
    else
      removeClass('ui-auto');
  }

  void addCol(Container col) {
    append(col);
    addClass('ui-column');
  }

  void addSlider() {
    final col = new Container();
    CLElement prev, next, res;
    num prev_width, next_width;
    Rectangle box;

    Container getPrevCol(Container cur) {
      Container c;
      for (var i = 0; i < containers.length; i++)
        if (containers[i] == cur) c = containers[i - 1];
      return c;
    }

    Container getNextCol(Container cur) {
      Container c;
      for (var i = 0; i < containers.length; i++)
        if (containers[i] == cur) c = containers[i + 1];
      return c;
    }

    final drag = new Drag(col, namespace: 'slider');
    drag
      ..start((e) {
        e.stopPropagation();
        prev = getPrevCol(col);
        next = getNextCol(col);
        prev_width = prev.getWidth();
        next_width = next.getWidth();
        res = new CLElement(new DivElement())..setClass('ui-slider-shadow');
        box = col.getRectangle();
        res.setRectangle(box);
        document.body.append(res.dom);
      })
      ..on((e) {
        final min_p = prev_width + drag.dx - 150;
        if (min_p < 0) drag.dx -= min_p;
        final min_n = next_width - drag.dx - 150;
        if (min_n < 0) drag.dx += min_n;
        res.setStyle({'left': '${box.left + drag.dx}px'});
      })
      ..end((e) {
        res.remove();
        prev.setWidth(new Dimension.px(prev_width + drag.dx));
        //Not needed - FlexBox takes care for sizing
        //next.setWidth(next_width - drag.dx);
      });

    append(col);
    col.setClass('ui-slider');
  }

  void addRow(Container row) {
    append(row);
    addClass('ui-row');
  }

  void insertRowBefore(Container row, Container before) {
    insertBefore(row, before);
    addClass('ui-row');
  }

  Container operator [](int index) => containers[index];

  void append(dynamic child, {bool scrollable = false}) {
    super.append(child);
    if (child is Container) {
      containers.add(child);
      child.parent = this;
    }
    if (scrollable) scroll = new CLscroll(dom);
  }

  void insertBefore(dynamic child, dynamic before, {bool scrollable = false}) {
    super.insertBefore(child, before);
    if (child is Container) {
      containers.add(child);
      child.parent = this;
    }
    if (scrollable) scroll = new CLscroll(dom);
  }

  void initLayout() => containers.forEach((c) => c.initLayout());
}
