part of app;

class Bubble extends CLElement {
  CLElement cont;
  late utils.Boxing boxing;
  static int _id = 0;
  StreamSubscription? _subscr;
  bool _visible = false;
  bool countZIndex;

  Bubble(this.cont, {String type = 'warning', this.countZIndex = false})
      : super(new AnchorElement()) {
    setClass('ui-hint $type');
    addAction((e) => showBubble(), 'mouseover');
    addAction((e) => hideBubble(), 'mouseout');
    boxing = new utils.Boxing([
      utils.BoxingPosition.topRight,
      utils.BoxingPosition.bottomRight,
      utils.BoxingPosition.topLeft,
      utils.BoxingPosition.bottomLeft,
      utils.BoxingPosition.rightBottom,
      utils.BoxingPosition.leftBottom,
      utils.BoxingPosition.leftTop,
      utils.BoxingPosition.rightTop,
      utils.BoxingPosition.finalPosition
    ], offset: 10, verticalAlignContent: true);
    addClass('ui-hint-bubble');
    cont.dom.id = 'bubble${++_id}';
  }

  void showBubble() => _showHint();

  void hideBubble() => _closeHint();

  void _showHint() {
    if (_visible) return;
    _visible = true;
    document.body!.querySelectorAll('a.ui-hint-bubble').forEach((el) {
      new CLElement(el)
        ..setStyle({'left': 'initial', 'top': 'initial'})
        ..removeClass('top-right bottom-right top-left bottom-left show')
        ..removeClass('show')
        ..remove();
    });
    if (document.body!.querySelector('#bubble$_id') == null) return;

    final ref = cont.getMutableRectangle();
    final body = document.body!.getBoundingClientRect();
    appendTo(document.body);
    final r = getRectangle();

    final func = boxing.runTest(ref, r, body);
    // Execute changes of ref's bounding box
    if (func != null) {
      if (boxing.topRight != null) addClass('top-right');
      if (boxing.bottomRight != null) addClass('bottom-right');
      if (boxing.topLeft != null) addClass('top-left');
      if (boxing.bottomLeft != null) addClass('bottom-left');
      if (boxing.leftTop != null) addClass('left-top');
      if (boxing.rightTop != null) addClass('right-top');
      if (boxing.leftBottom != null) addClass('left-bottom');
      if (boxing.rightBottom != null) addClass('right-bottom');
      if (boxing.finalPosition != null) {}
      func();
    }

    setStyle({'left': '${ref.left}px', 'top': '${ref.top}px'});
    if (countZIndex) {
      final zIndex = _findZIndex();
      if (zIndex != null) setStyle({'z-index': zIndex});
    }

    new Timer(const Duration(milliseconds: 0), () => addClass('show'));
    _subscr?.cancel();

    void _close(e) {
      _closeHint();
      window.removeEventListener('scroll', _close);
    }

    window.addEventListener('scroll', _close, true);
  }

  String? _findZIndex() {
    String? zIndex;
    Element? parent = cont.dom;
    while (parent != null && zIndex == null) {
      if (parent.style.zIndex.isNotEmpty) zIndex = parent.style.zIndex;
      parent = parent.parent;
    }
    return zIndex;
  }

  void _closeHint() {
    _visible = false;
    setStyle({'left': 'initial', 'top': 'initial'});
    removeClass('top-right bottom-right top-left bottom-left show');
    remove();
  }
}

class Hint extends CLElement {
  String key;
  Future<String?> Function(String) loadData;
  int time = 300;
  String? data;
  Timer? _timerShow, _timerClose;
  final List<Function> _tests = [];
  late CLElement hintDom;

  Hint(this.key, this.loadData) : super(new AnchorElement()) {
    setHtml('?');
    setClass('ui-hint-spot');
    addAction(_startShow, 'mouseover');
    addAction(_stopShow, 'mouseout');
    addAction(_startClose, 'mouseout');

    _tests.addAll([tryBottomLeft, tryBottomRight, tryTopLeft, tryTopRight]);

    hintDom = new CLElement(new DivElement())
      ..setClass('ui-hint message')
      ..addAction(_stopClose, 'mouseover')
      ..addAction(_startClose, 'mouseout');
  }

  void renderData(String? data) {
    hintDom.setHtml(data ?? '');
  }

  void _startShow(e) {
    if (data == null) loadData(key).then(renderData);
    _timerShow = new Timer(new Duration(milliseconds: time), () => showHint(e));
  }

  void _stopShow(e) => _timerShow?.cancel();

  void _startClose(e) =>
      _timerClose = new Timer(new Duration(milliseconds: time), _closeHint);

  void _stopClose(e) => _timerClose?.cancel();

  void showHint(MouseEvent e) {
    final ref = getMutableRectangle();
    final body = document.body!.getBoundingClientRect();
    hintDom.appendTo(document.body);
    final r = hintDom.getRectangle();

    var way = false;
    var i = 0;
    while (!way && i < _tests.length) way = _tests[i++](ref, r, body);

    hintDom.setStyle({'left': '${ref.left}px', 'top': '${ref.top}px'});
    new Timer(const Duration(milliseconds: 0), () => hintDom.addClass('show'));
  }

  bool tryBottomRight(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left + ref.width - r.width, ref.top,
        r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      hintDom.addClass('bottom-right');
      ref
        ..left = ref.left + ref.width - r.width - 30
        ..top -= 10;
    }
    return res;
  }

  bool tryBottomLeft(
      math.MutableRectangle ref, math.Rectangle el, math.Rectangle body) {
    final testRect =
        new Rectangle(ref.left, ref.top, el.width, ref.height + el.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      hintDom.addClass('bottom-left');
      ref
        ..left += 30
        ..top -= 10;
    }
    return res;
  }

  bool tryTopLeft(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(
        ref.left, ref.top - r.height, r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      hintDom.addClass('top-left');
      ref
        ..top -= r.height - 20
        ..left += 30;
    }
    return res;
  }

  bool tryTopRight(
      math.MutableRectangle ref, math.Rectangle r, math.Rectangle body) {
    final testRect = new Rectangle(ref.left + ref.width - r.width,
        ref.top - r.height, r.width, ref.height + r.height);
    final res = body.containsRectangle(testRect);
    if (res) {
      hintDom.addClass('top-right');
      ref
        ..left = ref.left + ref.width - r.width - 30
        ..top -= r.height - 20;
    }
    return res;
  }

  void _closeHint() => hintDom
    ..setStyle({'left': 'initial', 'top': 'initial'})
    ..removeClass('bottom-right bottom-left top-right top-left')
    ..removeClass('show')
    ..remove();
}

class BubbleVisualizer {
  bool _closed = true;

  BubbleVisualizer(CLElement cont, FutureOr<DivElement?> Function() execute,
      {String type = 'message', String? clas}) {
    Bubble? bubble;
    cont
      ..addAction<MouseEvent>((event) async {
        if (!utils.eventWithinSource(event, cont.dom)) return;
        _closed = false;
        final c = await execute();
        if (c == null || _closed || !utils.eventWithinSource(event, cont.dom))
          return;
        bubble = new Bubble(cont, type: type)
          ..dom.append(c)
          ..showBubble();
        if (clas != null) bubble!.addClass(clas);
      }, 'mouseover')
      ..addAction<MouseEvent>((event) {
        if (utils.eventWithinSource(event, cont.dom)) {
          bubble?.hideBubble();
          _closed = true;
        }
      }, 'mouseout');
  }
}

class HintManager {
  Future<String> Function(String) loadHint;
  String? position;

  HintManager(this.loadHint, [this.position]);

  CLElement get(String title, String key) {
    final c = new CLElement(new SpanElement())..setText(title);
    new Hint(key, loadHint).appendTo(c);
    return c;
  }
}
