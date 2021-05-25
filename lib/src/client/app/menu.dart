part of app;

class Menu extends CLElement {
  Application ap;
  late CLElement container;
  late CLElement control;
  late MenuElementRendererBase renderer;

  List<MenuElement> mainElements = [];
  List<MenuElement> hidden = [];

  bool active = false;

  Menu(this.ap) : super(new DivElement()) {
    addClass('ui-main-menu');
    container = new CLElement(new Element.ul());
    append(container);
    control = new CLElement(new AnchorElement())
      ..addClass('ui-menu-control')
      ..append(new Icon(Icon.chevron_left).dom)
      ..addAction((e) {
        ap.menuHide();
      });
    ap.fieldLeft.append(control);
    ap.fieldLeft.append(this);
    if (ap.settings.menuStyle == 1) {
      renderer = new MenuElementRenderer(ap);
    } else if (ap.settings.menuStyle == 2) {
      ap.page.addClass('type2');
      renderer = new MenuElementRenderer2(ap);
    }
  }

  void closeMenu([Event? e]) {
    mainElements.forEach((me) {
      me.forEachChilds(renderer.closeSub, inclCurrent: true);
    });
  }

  void closeMenuAtLevel(int level) {
    MenuElement._index.forEach((k, el) {
      if (el.level == level && el.existClass('selected'))
        el.forEachChilds(renderer.closeSub, inclCurrent: true);
    });
  }

  void setMenu(List<MenuElement> arr) {
    mainElements.addAll(arr);
  }

  void render() {
    mainElements.forEach((el) {
      el
        ..setLevel()
        .._init(this);
      container.append(el);
    });
    var level = MenuElement._max_level;
    while (level >= 0)
      MenuElement.findByLevel(level--).forEach(_cleanEmptyElement);
    new utils.CLscroll(dom);
  }

  void _cleanEmptyElement(MenuElement element) {
    if ((element.action == null && element.children.isEmpty) ||
        (element.scope != null && !ap.client.checkPermission(element.scope))) {
      if (element.parent != null)
        element.parent!.children.remove(element);
      else
        element.remove();
    }
  }

  List<DeskIcon> getDesktopIcons() {
    final icons = <DeskIcon>[];
    MenuElement._index.forEach((k, el) {
      if ((el.scope == null || ap.client.checkPermission(el.scope)) &&
          el.desktop)
        icons.add(new DeskIcon(ap,
            title: el.title ?? '',
            icon: el.icon ?? '',
            subTitle: el.description ?? '',
            action: el.action ?? (ap) {}));
    });
    return icons;
  }
}

class MenuElement extends CLElement {
  static int _key = 1;

  String? key;
  String? title, icon, scope, description;
  bool desktop = false;
  Function(Application)? action;

  List<MenuElement> children = [];
  static final Map<String, MenuElement> _index = {};
  static int _max_level = 0;

  late Menu menu;

  MenuElement? parent;

  late CLElement domInner;

  CLElement? cont;
  CLElement? tip;
  Timer? timer;

  bool disable = false;

  int level = 0;

  num height = 0;

  MenuElement() : super(new Element.li()) {
    domInner = new CLElement(new AnchorElement())..appendTo(this);
  }

  void _init(Menu m) {
    key ??= '${_key++}__';
    _index[key!] = this;
    menu = m;
    createDom();
    menu.renderer.init(this);
    children.forEach((ch) => ch._init(menu));
  }

  void createDom() {
    setClass('ui-menu-element lvl$level');
    final spanTitle = new SpanElement()..text = title;
    domInner.append(spanTitle);
    if (icon != null) {
      final ic = new Icon(icon!);
      domInner.dom.insertBefore(ic.dom, spanTitle);
    }
  }

  void setLevel() {
    if (parent != null) level = parent!.level + 1;
    _max_level = math.max(_max_level, level);
    children.forEach((ch) => ch.setLevel());
  }

  MenuElement addChild(MenuElement child) {
    child.parent = this;
    children.add(child);
    return child;
  }

  static MenuElement? findElement(String ref) {
    if (_index[ref] != null) return _index[ref];
    return null;
  }

  static Iterable<MenuElement> findByLevel(int level) =>
      _index.values.where((el) => el.level == level);

  void removeMenuChild(MenuElement el) {
    _index.remove(el.key);
    children.remove(el);
  }

  void forEachParents(void Function(MenuElement) f,
      {bool inclCurrent = false}) {
    if (inclCurrent) f(this);
    var p = parent;
    while (p != null) {
      f(p);
      p = p.parent;
    }
  }

  void forEachChilds(void Function(MenuElement) f, {bool inclCurrent = false}) {
    if (inclCurrent) f(this);
    children.forEach((child) {
      child.forEachChilds(f);
      f(child);
    });
  }
}

abstract class MenuElementRendererBase {
  Application ap;

  MenuElementRendererBase(this.ap);

  void init(MenuElement element);

  void closeSub(MenuElement element);

  void showSub(MenuElement element);
}

class MenuElementRenderer extends MenuElementRendererBase {
  MenuElementRenderer(ap) : super(ap);

  @override
  void init(MenuElement element) {
    element.domInner.addAction<Event>((e) {
      if (ap.disabledNavigation) return;
      e
        ..stopPropagation()
        ..preventDefault();
      if (element.disable) return;
      if (element.action is Function) {
        if (element.menu.ap.settings.menuHideOnAction)
          element.menu.ap.menuHide();
        element.action!(ap);
        element.menu.closeMenu();
        element.menu.active = false;
      } else {
        if (!element.menu.active) {
          if (element.level == 0) element.menu.active = true;
          showSub(element);
        } else {
          if (element.level == 0) {
            element.menu.active = false;
            element.menu.closeMenu();
          }
        }
      }
      late StreamSubscription document_click;
      document_click = document.onClick.listen((e) {
        element.menu.active = false;
        element.menu.closeMenu();
        document_click.cancel();
      });
    }, 'click');
    element
      ..addAction((e) => showSub(element), 'mouseenter')
      ..addAction((e) {
        if (!element.menu.active) {
          final rect = element.getRectangle();
          element
            ..tip = (new CLElement(new DivElement())
              ..addClass('ui-data-tip right-tip')
              ..setAttribute('data-tips', element.title ?? '')
              ..setStyle({
                'top': '${rect.top + 13}px',
                'left': '${rect.left + rect.width}px'
              })
              ..appendTo(document.body))
            ..timer = new Timer(const Duration(milliseconds: 100),
                () => element.tip!.addClass('show'));
        }
      }, 'mouseover');
    void _remove(e) {
      if (!element.menu.active &&
          element.timer != null &&
          element.tip != null) {
        element.timer!.cancel();
        element.tip!.remove();
      }
    }

    element..addAction(_remove, 'mouseout')..addAction(_remove, 'mousedown');
  }

  @override
  void showSub(MenuElement element) {
    if (ap.disabledNavigation) return;
    if (!element.menu.active) return;
    element.menu.closeMenuAtLevel(element.level);
    element.forEachParents((e) => e.addClass('selected'), inclCurrent: true);
    if (element.children.isEmpty) return;
    if (element.cont == null) {
      element.cont = new CLElement(new Element.ul())..setClass('ui-sub-menu');
      element.children.forEach((child) {
        element.cont!.append(child);
        if (child.children.isNotEmpty)
          child.domInner.append(new SpanElement()
            ..classes.add('sub')
            ..text = '►');
      });
      _appendSub(element);
      _posCont(element);
    } else {
      _appendSub(element);
    }
    _fixHeight(element);
    element.cont?.addClass('show');
  }

  @override
  void closeSub(MenuElement element) {
    if (element.cont != null) {
      element.cont!.removeClass('show');
      element.cont!.remove();
    }
    element.removeClass('selected');
  }

  void _appendSub(MenuElement element) {
    element.menu.ap.page.dom.insertBefore(
        element.cont!.dom,
        (element.parent != null)
            ? element.parent!.cont!.dom
            : element.menu.ap.page.dom.lastChild);
  }

  void _posCont(MenuElement element) {
    final pos = element.getRectangle();
    final height = element.children
        .fold(0, (height, child) => height ?? 0 + child.getHeight());
    final left = pos.left + pos.width;
    element.cont!.setStyle(
        {'top': '${pos.top}px', 'left': '${left}px', 'height': '${height}px'});
  }

  void _fixHeight(MenuElement element) {
    final pos = element.getRectangle();
    final reach = pos.top + element.cont!.getHeight();
    final diff = reach -
        new CLElement(element.menu.ap.page).getHeight() +
        document.body!.scrollTop;
    var top = pos.top;
    if (diff > 0) top -= diff;
    element.cont!.setStyle({'top': '${top + document.body!.scrollTop}px'});
  }
}

class MenuElementRenderer2 extends MenuElementRendererBase {
  MenuElementRenderer2(ap) : super(ap);

  @override
  void init(MenuElement element) {
    element.domInner.addAction<Event>((e) {
      e
        ..stopPropagation()
        ..preventDefault();
      if (element.disable) return;
      if (element.action is Function) {
        if (element.menu.ap.settings.menuHideOnAction)
          element.menu.ap.menuHide();
        element.action!(ap);
      } else {
        element.menu.active = true;
        showSub(element);
      }
    }, 'click');
    element.addAction((e) {
      if (!element.menu.active) {
        final rect = element.getRectangle();
        element
          ..tip = (new CLElement(new DivElement())
            ..addClass('ui-data-tip right-tip')
            ..setAttribute('data-tips', element.title ?? '')
            ..setStyle({
              'top': '${rect.top + 13}px',
              'left': '${rect.left + rect.width}px'
            })
            ..appendTo(document.body))
          ..timer = new Timer(const Duration(milliseconds: 100),
              () => element.tip!.addClass('show'));
      }
    }, 'mouseover');
    void _remove(e) {
      if (!element.menu.active &&
          element.timer != null &&
          element.tip != null) {
        element.timer!.cancel();
        element.tip!.remove();
      }
    }

    element..addAction(_remove, 'mouseout')..addAction(_remove, 'mousedown');
  }

  @override
  Future showSub(MenuElement element) async {
    if (!element.menu.active) return null;
    if (element.children.isEmpty) return null;
    if (element.existClass('selected')) {
      closeMenuAtLevel(element.level);
      return null;
    }
    closeMenuAtLevel(element.level);
    element.forEachParents((e) => e.addClass('selected'), inclCurrent: true);
    if (element.cont == null) {
      element.cont = new CLElement(new Element.ul())..setClass('ui-sub-inner');
      element.children.forEach((child) => element.cont!.append(child));
      element
        ..append(element.cont)
        ..height = element.children
            .fold(0, (height, child) => height + child.getHeight());
    }
    //await new Future.delayed(new Duration(milliseconds:400));
    var h = 0;
    element.forEachParents((e) {
      e.cont!.setStyle({
        'height': '${(h == 0 ? 0 : e.cont!.getHeight()) + element.height}px'
      });
      h++;
    }, inclCurrent: true);
  }

  void closeMenuAtLevel(int level) {
    MenuElement._index.forEach((k, el) {
      if (el.level == level && el.existClass('selected')) {
        el.forEachChilds(closeSub, inclCurrent: true);
        if (el.parent != null) {
          num h = 0;
          el.forEachParents((e) {
            e.cont!.setStyle({'height': '${e.height + h}px'});
            if (e.existClass('selected')) h += e.height;
          });
        }
      }
    });
  }

  @override
  void closeSub(MenuElement element) {
    element.cont?.setStyle({'height': '0'});
    element.removeClass('selected');
  }
}

class DeskIcon extends Container {
  Application ap;
  final String icon;
  final String title;
  final String subTitle;
  void Function(Application) action;

  DeskIcon(this.ap,
      {required this.icon,
      required this.title,
      required this.subTitle,
      required this.action})
      : super(new DivElement()) {
    createDom();
    addAction((e) => action(ap));
  }

  void createDom() {
    append(new Icon(icon).dom);
    new CLElement(new SpanElement())
      ..addClass('title')
      ..setText(title)
      ..appendTo(this);
    new CLElement(new SpanElement())
      ..addClass('sub')
      ..setText(subTitle)
      ..appendTo(this);
  }
}
