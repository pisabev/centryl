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

num __scrollBarWidth = 0;

num getScrollbarWidth() {
  if (__scrollBarWidth != 0) return __scrollBarWidth;
  final outer = new DivElement()
    ..style.width = '100px'
    ..style.height = '100px';
  document.body!.append(outer);
  final widthNoScroll = outer.offsetWidth;
  outer.style.overflow = 'scroll';
  final inner = document.createElement('div')..style.width = '100%';
  outer.append(inner);
  final widthWithScroll = inner.offsetWidth;
  outer.remove();
  return __scrollBarWidth = widthNoScroll - widthWithScroll;
}

Function debounce(Function func, Duration wait, [bool immediate = true]) {
  Timer? timeout;
  return () {
    final later = () {
      timeout = null;
      if (!immediate) func();
    };
    final callNow = immediate && timeout == null;
    timeout?.cancel();
    timeout = new Timer(wait, later);
    if (callNow) func();
  };
}

Function throttle(Function func, Duration wait) {
  Timer? timeout;
  return () {
    if (timeout != null) return;
    func();
    timeout = new Timer(wait, () => timeout = null);
  };
}

bool eventWithinSource(MouseEvent event, Element cont) {
  Element? el = event.relatedTarget as Element;
  while (el != null) {
    if (el == cont) {
      return false;
    }
    if (el.parentNode is HtmlDocument)
      el = null;
    else
      el = el.parentNode as Element;
  }
  return true;
}

Element? getScrollParent(Element? node) {
  if (node == null) {
    return null;
  }
  if (node.scrollHeight > node.clientHeight) {
    return node;
  } else {
    if (node.parentNode is! Element) return null;
    return getScrollParent(node.parentNode as Element);
  }
}

void printUrl(String url, [CLElement? load]) {
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
  document.body!.append(ifr);
}
