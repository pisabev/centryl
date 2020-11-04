part of utils;

math.Point boundPoint(math.Point p, math.Point ref1, math.Point ref2) {
  math.Point max(math.Point p, math.Point ref) =>
      new math.Point(math.max(p.x, ref.x), math.max(p.y, ref.y));
  math.Point min(math.Point p, math.Point ref) =>
      new math.Point(math.min(p.x, ref.x), math.min(p.y, ref.y));
  return min(max(p, ref1), ref2);
}

math.MutableRectangle boundRect(Rectangle rect, Rectangle ref) {
  final left = (rect.left < ref.left)
      ? ref.left
      : math.min(rect.left, ref.left + ref.width - rect.width);
  final top = (rect.top < ref.top)
      ? ref.top
      : math.min(rect.top, ref.top + ref.height - rect.height);
  return new math.MutableRectangle(left, top, rect.width, rect.height);
}

math.MutableRectangle centerRect(Rectangle rect, Rectangle ref) {
  final box =
      new math.MutableRectangle.fromPoints(rect.topLeft, rect.bottomRight);
  box
    ..left = ref.left + ref.width ~/ 2 - box.width ~/ 2
    ..top = ref.top + ref.height ~/ 2 - box.height ~/ 2;
  return box;
}

num __scrollBarWidth;

num getScrollbarWidth() {
  if (__scrollBarWidth != null) return __scrollBarWidth;
  final outer = new DivElement()
    ..style.width = '100px'
    ..style.height = '100px';
  document.body.append(outer);
  final widthNoScroll = outer.offsetWidth;
  outer.style.overflow = 'scroll';
  final inner = document.createElement('div')..style.width = '100%';
  outer.append(inner);
  final widthWithScroll = inner.offsetWidth;
  outer.remove();
  return __scrollBarWidth = widthNoScroll - widthWithScroll;
}

Function debounce(Function func, Duration wait, [bool immediate = true]) {
  Timer timeout;
  return () {
    final later = () {
      timeout = null;
      if (!immediate) func();
    };
    final callNow = immediate && timeout == null;
    if (timeout != null) timeout.cancel();
    timeout = new Timer(wait, later);
    if (callNow) func();
  };
}

Function throttle(Function func, Duration wait) {
  Timer timeout;
  return () {
    if (timeout != null) return;
    func();
    timeout = new Timer(wait, () => timeout = null);
  };
}

class UISlider {
  static const int BOTTOMLEFT = 1;
  static const int TOPLEFT = 2;
  static const int BOTTOMRIGHT = 3;
  static const int TOPRIGHT = 4;

  bool autoWidth = true;
  Boxing boxing;
  bool appendDom;
  CLElementBase parent;
  CLElementBase el;

  UISlider(this.el, this.parent,
      {this.appendDom = false, List<BoxingPosition> positions}) {
    el.addClass('ui-slide');
    boxing = new Boxing(positions);
  }

  void show([CLElementBase relativeTo, String zIndex]) {
    final body = (zIndex != null)
        ? (document.getElementsByClassName('ui-desktop').first as Element)
            .getBoundingClientRect()
        : document.body.getBoundingClientRect();

    relativeTo ??= parent;
    document.body.append(el.dom);

    final ref = relativeTo.getMutableRectangle();
    if (autoWidth) el.setStyle({'width': '${ref.width}px'});
    el.show();

    var r = el.getRectangle();
    Function func = boxing.runTest(ref, r, body);
    if (func == null) {
      // TODO check if element's position is nearer to the bottom of the screen
      el.setStyle({
        'max-height':
            '${r.height - ref.height - (ref.top + r.height - body.height)}px'
      });
      r = el.getRectangle();
      func = boxing.runTest(ref, r, body);
    }

    // Execute changes of ref's bounding box
    if (func != null) {
      if (boxing.topLeft != null || boxing.topRight != null) el.addClass('top');
      func();
    }

    el.setStyle({'left': '${ref.left}px', 'top': '${ref.top}px'});
    if (zIndex != null) el.setStyle({'z-index': zIndex});
    new Timer(const Duration(milliseconds: 0), () => el.addClass('show'));
  }

  void hide() {
    el
      ..hide()
      ..setStyle({'left': 'initial', 'top': 'initial'})
      ..removeClass('show'); //..removeClass('top');
    if (!appendDom)
      parent.append(el);
    else
      el.remove();
  }
}

bool eventWithinSource(MouseEvent event, Element cont) {
  Element el = event.relatedTarget as Element;
  while (el != null) {
    if (el == cont) {
      return false;
    }
    if (el.parentNode is HtmlDocument)
      el = null;
    else
      el = el.parentNode;
  }
  return true;
}

Element getScrollParent(Element node) {
  if (node == null) {
    return null;
  }
  if (node.scrollHeight > node.clientHeight) {
    return node;
  } else {
    if (node.parentNode is! Element) return null;
    return getScrollParent(node.parentNode);
  }
}

enum BoxingPosition {
  bottomLeft,
  topLeft,
  bottomRight,
  topRight,
  leftTop,
  leftBottom,
  rightTop,
  rightBottom,
  finalPosition
}

class Boxing {
  Function bottomLeft;
  Function bottomRight;
  Function topLeft;
  Function topRight;
  Function leftTop;
  Function leftBottom;
  Function rightTop;
  Function rightBottom;
  Function finalPosition;
  int offset;
  bool verticalAlignContent;

  List<BoxingPosition> order;

  Boxing(this.order, {this.offset = 0, this.verticalAlignContent = false}) {
    order ??= [
      BoxingPosition.bottomLeft,
      BoxingPosition.topLeft,
      BoxingPosition.bottomRight,
      BoxingPosition.topRight,
    ];
  }

  Function runTest(
      math.MutableRectangle ref, math.Rectangle el, math.Rectangle body) {
    bottomLeft = null;
    bottomRight = null;
    topLeft = null;
    topRight = null;
    leftTop = null;
    leftBottom = null;
    rightTop = null;
    rightBottom = null;
    Function found;
    for (final o in order) {
      if (found != null) break;
      switch (o) {
        case BoxingPosition.bottomLeft:
          if (tryBottomLeft(ref, el, body)) found = bottomLeft;
          break;
        case BoxingPosition.bottomRight:
          if (tryBottomRight(ref, el, body)) found = bottomRight;
          break;
        case BoxingPosition.topLeft:
          if (tryTopLeft(ref, el, body)) found = topLeft;
          break;
        case BoxingPosition.topRight:
          if (tryTopRight(ref, el, body)) found = topRight;
          break;
        case BoxingPosition.leftTop:
          if (tryLeftTop(ref, el, body)) found = leftTop;
          break;
        case BoxingPosition.leftBottom:
          if (tryLeftBottom(ref, el, body)) found = leftBottom;
          break;
        case BoxingPosition.rightTop:
          if (tryRightTop(ref, el, body)) found = rightTop;
          break;
        case BoxingPosition.rightBottom:
          if (tryRightBottom(ref, el, body)) found = rightBottom;
          break;
        case BoxingPosition.finalPosition:
          if (tryFinalPosition(ref, el, body)) found = finalPosition;
          break;
      }
    }
    return found;
  }

  ///
  /// --------
  /// |      |
  /// |      |
  /// --------
  /// □□□
  bool tryBottomLeft(
      math.MutableRectangle ref, math.Rectangle el, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left, ref.top + offset, el.width, ref.height + el.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      bottomLeft = () => ref..top += ref.height + offset;
    }
    return res;
  }

  ///
  /// --------
  /// |      |
  /// |      |
  /// --------
  ///      □□□
  bool tryBottomRight(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left + ref.width - r.width,
        ref.top + offset, r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      bottomRight = () => ref
        ..top += ref.height + offset
        ..left = ref.left + ref.width - r.width;
    }
    return res;
  }

  /// □□□
  /// --------
  /// |      |
  /// |      |
  /// --------
  bool tryTopLeft(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left, ref.top - (r.height + offset),
        r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      topLeft = () => ref..top -= r.height + offset;
    }
    return res;
  }

  ///      □□□
  /// --------
  /// |      |
  /// |      |
  /// --------
  bool tryTopRight(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left + ref.width - r.width,
        ref.top - (r.height + offset), r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      topRight = () => ref
        ..top -= r.height + offset
        ..left = ref.left + ref.width - r.width;
    }
    return res;
  }

  /// □
  /// □
  /// □ --------
  /// □ |      |
  /// □ |      |
  /// □ --------
  bool tryLeftTop(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left - r.width - offset,
        ref.top - (r.height - ref.height), r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      leftTop = () => ref
        ..left = ref.left - r.width - offset
        ..top -= r.height - ref.height;
    }
    return res;
  }

  ///
  /// □ --------
  /// □ |      |
  /// □ |      |
  /// □ --------
  /// □
  /// □
  bool tryLeftBottom(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left - r.width - offset,
        verticalAlignContent ? (ref.top - r.height / 2) : ref.top,
        r.width,
        ref.height + r.height);
    final c = new DivElement()..style.background = 'red';
    final d = new CLElement(c)..setRectangle(testRect);
    document.body.append(d.dom);
    final res = body.containsRectangle(testRect);
    if (res) {
      leftBottom = () => ref
        ..left = ref.left - r.width - offset
        ..top = verticalAlignContent ? (ref.top - r.height / 2) : ref.top;
    }
    return res;
  }

  ///          □
  ///          □
  /// -------- □
  /// |      | □
  /// |      | □
  /// -------- □
  bool tryRightTop(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left - ref.width + offset,
        ref.top - (r.height - ref.height), r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      rightTop = () => ref
        ..left = ref.left + ref.width + offset
        ..top -= r.height - ref.height;
    }
    return res;
  }

  ///
  /// -------- □
  /// |      | □
  /// |      | □
  /// -------- □
  ///          □
  ///          □
  bool tryRightBottom(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left - ref.width + offset,
        verticalAlignContent ? (ref.top - r.height / 2) : ref.top,
        r.width,
        ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      rightBottom = () => ref
        ..left = ref.left + ref.width + offset
        ..top = verticalAlignContent ? (ref.top - r.height / 2) : ref.top;
    }
    return res;
  }

  bool tryFinalPosition(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    if (ref.left + r.width >= document.body.clientWidth) {
      finalPosition = () => ref
        ..left = ref.left - r.width - offset
        ..top = offset; //maybe something else
    } else {
      finalPosition = () => ref
        ..left = ref.left + ref.width + offset
        ..top = offset;
    }
    return true;
  }
}

void printUrl(String url, [CLElement load]) {
  final loader = new LoadElement(load ?? new CLElement(document.body));
  document.getElementById('iframe-print')?.remove();
  final ifr = new IFrameElement()..style.display = 'none';
  ifr
    ..id = 'iframe-print'
    ..onLoad.listen((e) async {
      loader.remove();
      ifr.focus();
      final obj =
          new JsObject.fromBrowserObject(ifr)['contentWindow'] as JsObject;
      if (obj.hasProperty('print')) obj.callMethod('print');
    })
    ..src = url.replaceAll(new RegExp(r'/{2,}'), '/');
  document.body.append(ifr);
}
