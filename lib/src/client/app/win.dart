part of app;

class Win {
  CLElement container;
  static String hookLayout = 'layout';
  static String hookRender = 'render';
  static String hookClose = 'close';
  static String hookResize = 'resize';
  static String hookFocus = 'focus';
  static String hookMinimize = 'minimize';
  static String hookMaximize = 'maximize';

  late Container win;
  late Container win_top;
  late Container win_body;

  late CLElement win_title;
  late CLElement win_close;
  late CLElement win_max;
  late CLElement win_min;

  late utils.CLscroll scroll;

  bool visible = true;

  final WinType type;

  late math.MutableRectangle body;
  late math.MutableRectangle box;
  late math.MutableRectangle box_h;

  final StreamController<bool> _contr = new StreamController.broadcast();

  bool isActive = true;
  bool _maximized = false;
  int _zIndex = 0;

  final num _min_width = 350;
  final num _min_height = 100;

  late CLElement _resize_cont;
  Rectangle? _resize_rect;
  late Map<String, CLElement> _resize_contr;

  late math.Point _win_res_pos;

  late utils.Observer observer;

  final List<utils.KeyAction> _key_actions = [];

  Win(this.container, {this.type = WinType.normal}) {
    _createHtml();
    _setWinActions();
    observer = new utils.Observer();
    win.dom.tabIndex = 0;
    observer.addHook(hookFocus, (_) {
      win.dom.focus();
      return true;
    });
    win.addAction<Event>(
        (e) => _key_actions.forEach((action) => action.run(e)), 'keydown');
  }

  void _createHtml() {
    win = new Container()..addClass('ui-win');
    win_top = new Container()
      ..addClass('title')
      ..addAction((e) => maximize(), 'dblclick');
    win_body = new Container()
      ..addClass('content')
      ..auto = true;

    win_title = new CLElement(new HeadingElement.h3())..dom.text = 'Win';
    win_close = new CLElement(new AnchorElement())
      ..setClass('ui-win-close')
      ..addAction((e) => close(), 'click');
    win_max = new CLElement(new AnchorElement())
      ..setClass('ui-win-max')
      ..addAction((e) => maximize(), 'click');
    win_min = new CLElement(new AnchorElement())
      ..setClass('ui-win-min')
      ..addAction((e) => minimize(), 'click');

    win_top
      ..append(win_title)
      ..append(win_min)
      ..append(win_max)
      ..append(win_close);

    win..addRow(win_top)..addRow(win_body);

    final top_left = new CLElement(new DivElement())
      ..setClass('ui-win-corner-top-left');
    final top_right = new CLElement(new DivElement())
      ..setClass('ui-win-corner-top-right');
    final bottom_left = new CLElement(new DivElement())
      ..setClass('ui-win-corner-bottom-left');
    final bottom_right = new CLElement(new DivElement())
      ..setClass('ui-win-corner-bottom-right');
    final top = new CLElement(new DivElement())..setClass('ui-win-top');
    final right = new CLElement(new DivElement())..setClass('ui-win-right');
    final bottom = new CLElement(new DivElement())..setClass('ui-win-bottom');
    final left = new CLElement(new DivElement())..setClass('ui-win-left');

    _resize_cont = new CLElement(new DivElement())..setClass('ui-win-resize');
    _resize_contr = <String, CLElement>{
      't_c': top..appendTo(win),
      'r_c': right..appendTo(win),
      'b_c': bottom..appendTo(win),
      'l_c': left..appendTo(win),
      't_l_c': top_left..appendTo(win),
      't_r_c': top_right..appendTo(win),
      'b_l_c': bottom_left..appendTo(win),
      'b_r_c': bottom_right..appendTo(win)
    };
  }

  void _setWinActions() {
    late utils.Drag drag;
    drag = new utils.Drag(win_top, namespace: 'stop')
      ..context = win
      ..bound = container
      ..start((e) {
        win.addClass('drag');
      })
      ..on((e) {
        e.stopPropagation();
        setPosition(drag.rect!.left, drag.rect!.top);
      })
      ..end((e) => win.removeClass('drag'));

    new utils.Drag(_resize_contr['t_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('N', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['r_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('E', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['b_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('S', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['l_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('W', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['t_l_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('NW', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['t_r_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('NE', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['b_l_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('SW', e))
      ..end(_winResizeAfter);
    new utils.Drag(_resize_contr['b_r_c']!, namespace: 'stop')
      ..start(_winResizeBefore)
      ..on((e) => _winResizeOn('SE', e))
      ..end(_winResizeAfter);
  }

  void _winResizeBefore(MouseEvent e) {
    e.stopPropagation();
    _win_res_pos = new math.Point(e.page.x, e.page.y);
    win.addClass('transform');
    container.append(_resize_cont);
  }

  void _winResizeOn(String destination, MouseEvent e) {
    e.stopPropagation();
    final pos = new math.Point(e.page.x, e.page.y);
    // pos = pos.bound(new utils.Point(body.p.x, body.p.y),
    // new utils.Point(body.p.x + body.w - 10, body.p.y + body.h - 10));
    final diff_pos = _win_res_pos - pos;

    final Function(num, [String]) calc = (dim, [type = 'width']) =>
        (type == 'width')
            ? math.max(dim, _min_width)
            : math.max(dim, _min_height);

    final p =
        new math.MutableRectangle(box.left, box.top, box.width, box.height);

    switch (destination) {
      case 'N':
        p.height = calc(p.height + diff_pos.y, 'height');
        p.top = p.top + (box.height - p.height);
        break;
      case 'E':
        p.width = calc(p.width - diff_pos.x);
        break;
      case 'S':
        p.height = calc(p.height - diff_pos.y, 'height');
        break;
      case 'W':
        p.width = calc(p.width + diff_pos.x);
        p.left = p.left + (box.width - p.width);
        break;
      case 'SE':
        p.width = calc(p.width - diff_pos.x);
        p.height = calc(p.height - diff_pos.y, 'height');
        break;
      case 'SW':
        p.width = calc(p.width + diff_pos.x);
        p.height = calc(p.height - diff_pos.y, 'height');
        p.left = p.left + (box.width - p.width);
        break;
      case 'NW':
        p.width = calc(p.width + diff_pos.x);
        p.height = calc(p.height + diff_pos.y, 'height');
        p.left = p.left + (box.width - p.width);
        p.top = p.top + (box.height - p.height);
        break;
      case 'NE':
        p.width = calc(p.width - diff_pos.x);
        p.height = calc(p.height + diff_pos.y, 'height');
        p.top = p.top + (box.height - p.height);
        break;
    }

    _resize_cont
      ..setWidth(new Dimension.px(p.width))
      ..setHeight(new Dimension.px(p.height))
      ..setStyle({'left': '${p.left}px', 'top': '${p.top}px'});
    _resize_rect = p;
  }

  void _winResizeAfter(e) {
    _resize_cont.remove();
    if (_resize_rect != null) {
      setSize(_resize_rect!.width, _resize_rect!.height);
      setPosition(_resize_rect!.left, _resize_rect!.top);
      initLayout();
      _resize_rect = null;
    }
    win.removeClass('transform');
  }

  void setTitle(dynamic title) {
    win_title.removeChilds();
    if (title is CLElement) {
      win_title.append(title);
    } else {
      win_title.dom.text = title;
    }
  }

  void setIcon(String icon) {
    final ic = new Icon(icon);
    win_top.dom.insertBefore(ic.dom, win_title.dom);
  }

  void setZIndex(int zIndx) {
    _zIndex = zIndx;
    win.setStyle({'z-index': zIndx.toString()});
  }

  void maximize() {
    body = _getContainerRect();
    if (_maximized == true) {
      win.addClass('ui-win-shadowed');
      win_top.state = true;
      if (box_h.width == 0 && box_h.height == 0) {
        box_h
          ..width = box.width - 100
          ..height = box.height - 100
          ..left = 50
          ..top = 50;
      }
      setSize(box_h.width, box_h.height);
      setPosition(box_h.left, box_h.top);
      _maximized = false;
      observer.execHooks(hookMaximize);
      _resize_contr.forEach((k, v) => v.show());
      initLayout();
    } else {
      win.removeClass('ui-win-shadowed');
      box_h =
          new math.MutableRectangle(box.left, box.top, box.width, box.height);
      setSize(body.width, body.height);
      _maximized = true;
      observer.execHooks(hookMaximize);
      // win_top.state = false;
      _resize_contr.forEach((k, v) => v.hide());
      initPosition(body.left, body.top);
      initLayout();
    }
  }

  void minimize() {
    visible = false;
    if (observer.execHooks(hookMinimize))
      win.hide();
    else
      visible = true;
  }

  void show() {
    win.show();
    visible = true;
  }

  bool devicePhone() => document.body!.classes.contains('phone');

  math.MutableRectangle _getContainerRect() {
    final pos = container.getStyle('position');
    var rect = new math.MutableRectangle(
        container.dom.offset.left,
        container.dom.offset.top,
        container.dom.offset.width,
        container.dom.offset.height);
    if (pos == 'absolute' || pos == 'relative' || pos == 'fixed')
      rect = new math.MutableRectangle(0, 0, rect.width, rect.height);
    return rect;
  }

  void render([num width = 0, num height = 0, num left = 0, num top = 0]) {
    body = _getContainerRect();
    box = new math.MutableRectangle(0, 0, 0, 0);
    win.appendTo(container);
    final w = width;
    final h = height;
    if (((w == 0) && (h == 0)) ||
        (w == body.width && h == body.height) ||
        devicePhone()) {
      maximize();
    } else {
      final num contWidth = container.getWidthInner();
      final num contHeight = container.getHeightInner();
      final num winWidth = math.min(math.max(w, _min_width), contWidth);
      final num winHeight = math.min(math.max(h, _min_height), contHeight);
      if (contWidth == winWidth && contHeight == winHeight)
        maximize();
      else {
        win.addClass('ui-win-shadowed');
        _setWidth(math.min(math.max(w, _min_width), container.getWidthInner()));
        _setHeight(
            math.min(math.max(h, _min_height), container.getHeightInner()));
        observer.execHooks(hookResize);
        final x = left;
        final y = top;
        initPosition(x, y);
        initLayout();
      }
    }
    win.addClass('scale');
    observer.execHooks(hookRender);
  }

  void setPosition(num left, num top) {
    box
      ..top = top
      ..left = left;
    final m = {'top': '${top}px', 'left': '${left}px'};
    win.setStyle(m);
    _resize_cont.setStyle(m);
  }

  void setSize(num width, num height) {
    _setWidth(width);
    _setHeight(height);
    observer.execHooks(hookResize);
  }

  void _setWidth(num width) {
    box.width = width;
    win.setWidth(new Dimension.px(width));
    _resize_contr['t_c']!.setWidth(new Dimension.px(width));
    _resize_contr['b_c']!.setWidth(new Dimension.px(width));
    _resize_cont.setWidth(new Dimension.px(width));
  }

  void _setHeight(num height) {
    box.height = height;
    win.setHeight(new Dimension.px(height));
    _resize_contr['l_c']!.setHeight(new Dimension.px(height));
    _resize_contr['r_c']!.setHeight(new Dimension.px(height));
    _resize_cont.setHeight(new Dimension.px(height));
  }

  void initPosition([num x = 0, num y = 0]) {
    if (!_maximized) {
      box = utils.centerRect(box, body);
      if (x != 0 && y != 0)
        box = utils.boundRect(new Rectangle(x, y, box.width, box.height), body);
      setPosition(box.left + document.body!.scrollLeft,
          box.top + document.body!.scrollTop);
    } else {
      setPosition(body.left + document.body!.scrollLeft,
          body.top + document.body!.scrollTop);
    }
  }

  void activate() {
    isActive = true;
    win.show();
    _contr.add(true);
  }

  void inactivate() {
    isActive = false;
    win.hide(useVisibility: true);
    _contr.add(false);
  }

  Stream<bool> get onActiveStateChange => _contr.stream;

  void initLayout() {
    win.initLayout();
    observer.execHooks(hookLayout);
  }

  Container getContent() => win_body;

  void close() {
    if (observer.execHooks(hookClose)) {
      _resize_cont.remove();
      win.remove();
    }
  }

  void addKeyAction(utils.KeyAction action) => _key_actions.add(action);
}
