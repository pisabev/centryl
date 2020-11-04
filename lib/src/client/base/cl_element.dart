part of base;

typedef KeyboardEventFunction<E extends KeyboardEvent> = void Function(E e);
typedef EventFunction<E extends Event> = void Function(E e);

abstract class CLElementBase<E extends Element> {
  E dom;
  Map<String, Map<String, List<Function>>> _events = {};
  bool state = true;
  static Expando exp = new Expando();

  void setState(bool state) => this.state = state;

  void addAction<T extends Event>(EventFunction<T> func,
      [String event_space = 'click']) {
    final ev = event_space.split('.');
    if (_events[ev[0]] == null) _events[ev[0]] = {};

    final f = (e) => state ? func(e) : null;

    if (ev.length < 2) {
      var namespace = 0;
      while (_events[ev[0]]['space${namespace.toString()}'] is List)
        namespace++;
      ev.add('space${namespace.toString()}');
    }

    if (_events[ev[0]][ev[1]] == null) _events[ev[0]][ev[1]] = [];

    dom.addEventListener(ev[0], f);
    _events[ev[0]][ev[1]].add(f);
  }

  void removeAction([String event_space = '']) {
    if (event_space.isNotEmpty) {
      final ev = event_space.split('.');
      if (_events[ev[0]] != null) {
        if (ev.length == 2 && _events[ev[0]][ev[1]] != null) {
          _events[ev[0]][ev[1]]
              .forEach((func) => dom.removeEventListener(ev[0], func));
          _events[ev[0]].remove(ev[1]);
          if (_events[ev[0]].isEmpty) _events.remove([ev[0]]);
        } else {
          _events[ev[0]].forEach((nsp, data) {
            data.forEach((func) => dom.removeEventListener(ev[0], func));
          });
          _events.remove(ev[0]);
        }
      }
    } else {
      removeActionsAll();
    }
  }

  void removeActionsAll() {
    _events.forEach((type, m) {
      m.forEach((nsp, data) {
        data.forEach((func) => dom.removeEventListener(type, func));
      });
    });
    _events = {};
    exp[dom] = _events;
  }

  void addKeyAction(KeyboardEventFunction func) {
    setAttribute('tabindex', '0');
    addAction((e) {
      addAction((e) {
        func(e);
      }, 'keydown._key_action');
    }, 'focus');
    addAction((e) {
      removeAction('keydown._key_action');
    }, 'blur');
  }

  num getHeight() => borderEdge.height;

  num getHeightComputed() => getStyleNum('height');

  num getHeightInner() => paddingEdge.height;

  num getHeightContent() => contentEdge.height;

  num getHeightInnerShift() => paddingEdge.height - contentEdge.height;

  num getHeightOuterShift() => marginEdge.height - borderEdge.height;

  num getWidth() => borderEdge.width;

  num getWidthComputed() => getStyleNum('width');

  num getWidthInner() => paddingEdge.width;

  num getWidthContent() => contentEdge.width;

  num getWidthInnerShift() => paddingEdge.width - contentEdge.width;

  num getWidthOuterShift() => marginEdge.width - borderEdge.width;

  Rectangle getRectangle() => dom.getBoundingClientRect();

  CssRect get marginEdge => new _MarginCssRect(dom);

  CssRect get borderEdge => new _BorderCssRect(dom);

  CssRect get paddingEdge => new _PaddingCssRect(dom);

  CssRect get contentEdge => new _ContentCssRect(dom);

  math.MutableRectangle getMutableRectangle() {
    final rect = dom.getBoundingClientRect();
    return new math.MutableRectangle(
        rect.left, rect.top, rect.width, rect.height);
  }

  void setRectangle(Rectangle rect) {
    setStyle({
      'top': '${rect.top}px',
      'left': '${rect.left}px',
      'width': '${rect.width}px',
      'height': '${rect.height}px'
    });
  }

  String getStyle(String style) =>
      dom.getComputedStyle().getPropertyValue(style);

  num getStyleNum(String style) =>
      num.tryParse(getStyle(style).replaceAll('px', ''));

  void setHeight(Dimension dim) {
    dom.style.height = dim.toString();
  }

  void setWidth(Dimension dim) {
    dom.style.width = dim.toString();
  }

  void setStyle(Map<String, String> styleMap) {
    styleMap.forEach(dom.style.setProperty);
  }

  void setClass(String clas) {
    dom.classes.clear();
    clas.split(' ').forEach((l) => dom.classes.add(l));
  }

  void removeClass(String clas) {
    if (clas == null || clas.isEmpty) return;
    clas.split(' ').forEach((l) => dom.classes.remove(l));
  }

  void addClass(String clas) {
    if (clas == null || clas.isEmpty) return;
    clas.split(' ').forEach((l) => dom.classes.add(l));
  }

  void toggleClass(String clas) {
    if (existClass(clas))
      removeClass(clas);
    else
      addClass(clas);
  }

  bool existClass(String clas) => dom.classes.contains(clas);

  void setAttribute(String attr, String value) {
    dom.setAttribute(attr, value);
  }

  void hide({bool useVisibility = false}) {
    if (useVisibility)
      dom.style.visibility = 'hidden';
    else
      dom.style.display = 'none';
  }

  void show() {
    dom.style
      ..visibility = null
      ..display = null;
  }

  void remove() => dom.remove();

  void removeChilds() => dom.children.clear();

  void removeChildsByClass(String clas) {
    final toRemove = [];
    dom.children.forEach((child) {
      if (child.classes.contains(clas)) toRemove.add(child);
    });
    toRemove.forEach((child) => child.remove());
  }

  void removeChild(dynamic el) => el.remove();

  void append(dynamic child) {
    if (child is CLElementBase)
      dom.append(child.dom);
    else
      dom.append(child);
  }

  void prepend(dynamic child) {
    if (child is CLElementBase)
      dom.children.insert(0, child.dom);
    else
      dom.children.insert(0, child);
  }

  void insertBefore(dynamic child, dynamic before) {
    if (child is CLElementBase) {
      if (before is CLElementBase)
        dom.insertBefore(child.dom, before.dom);
      else
        dom.insertBefore(child.dom, before);
    } else {
      if (before is CLElementBase)
        dom.insertBefore(child, before.dom);
      else
        dom.insertBefore(child, before);
    }
  }

  void appendTo(dynamic parent) {
    if (parent is CLElementBase)
      parent.dom.append(dom);
    else
      parent.append(dom);
  }

  void setHtml(String html) {
    dom.innerHtml = html;
  }

  void setText(String text) {
    dom.text = text;
  }
}

class CLElement<E extends Element> extends CLElementBase<E> {
  CLElement(d) {
    dom = (d is CLElementBase) ? d.dom : d;
    if (CLElementBase.exp[dom] != null)
      _events = CLElementBase.exp[dom];
    else
      CLElementBase.exp[dom] = _events;
  }
}
