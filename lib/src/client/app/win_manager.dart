part of app;

class _WinC {
  String key;
  Item item;

  _WinC(this.key, this.item);
}

class WinTabContainer extends CLElement {
  Application ap;
  CLElement cont, but;
  List<WinTab> tabs;
  final Map<String, WinTab> _map = {};

  WinTabContainer(this.ap) : super(new DivElement()) {
    addClass('ui-tabs');
    addAction((e) {
      removeClass('show');
    });
    cont = new CLElement(new DivElement())..appendTo(this);
    but = new CLElement(new AnchorElement())
      ..addClass('ui-tabs-more')
      ..append(new Icon(Icon.arrow_drop_down).dom)
      ..addAction((e) {
        e.stopPropagation();
        toggleClass('show');
      })
      ..appendTo(this);
  }

  void setTab(Win w, WinTab tab) {
    cont.append(tab);
    _map[w.hashCode.toString()] = tab;
    _calcSize();
  }

  void _calcSize() {
    final availSize = ap.fieldTop.getWidthInner() -
        ap.fieldTop.dom.children
            .where((el) => !el.classes.contains('ui-tabs'))
            .fold(0, (s, el) => s + new CLElement(el).getWidth());
    if (100 * _map.keys.length > availSize)
      addClass('dropdown');
    else
      removeClass('dropdown');
  }

  WinTab getTab(Win w) => _map[w.hashCode.toString()];

  WinTab removeTab(Win w) {
    final tab = getTab(w);
    if (tab != null) {
      tab.remove();
      _map.remove(w.hashCode.toString());
      _calcSize();
    }
    return tab;
  }
}

class WinTab extends CLElement {
  String tabClas = 'ui-win-tab';
  CLElement _span;

  WinTab(String title, String icon) : super(new AnchorElement()) {
    setClass(tabClas);
    _span = new CLElement(new SpanElement())..appendTo(this);
    setTitle(title);
    if (icon != null) {
      final ic = new Icon(icon);
      dom.insertBefore(ic.dom, _span.dom);
    }
  }

  bool get isActive => existClass('active');

  void activate() => addClass('active');

  void inactivate() => removeClass('active');

  void setTitle(String title) {
    _span.dom.text = title;
  }
}

enum WinType { normal, bound }

class WinManager<C extends Client> {
  final Application app;
  final Registry registry;
  final List<Win> _cacheWins = [];
  static const int zIndexWin = 500;
  final Map<String, WinTab> _map = {};
  final Map<String, _WinC> _map_items = {};

  WinManager(this.app) : registry = new Registry();

  Item<C> run(String key, [List addParams]) {
    final obj = registry.get(key);
    if (obj != null) {
      if (obj.wapi != null) refreshWinTabs(obj.wapi.win);
      return obj;
    }

    final r = registry.getRoute(key);
    if (r != null) {
      final params = r.parse(key);
      if (addParams != null) params.addAll(addParams);
      final obj = r.func(app, params);
      registry.add(key, obj);
      if (obj.wapi != null) setItem(obj.wapi.win, new _WinC(key, obj));
      pushUrl(key);
      return obj;
    }
    return null;
  }

  void pushUrl(String urlSlug) =>
      window.history.pushState(urlSlug, '', '${app.baseurl}$urlSlug');

  Win loadWindow({@required String title, String icon, WinType type}) {
    final win = new Win(app.desktop, type: type)..setTitle(title);
    if (icon != null) win.setIcon(icon);

    win.observer
      ..addHook(Win.hookClose, (_) {
        removeWin(win);
        return true;
      })
      ..addHook(Win.hookMinimize, (_) {
        app.tabs.getTab(win).inactivate();
        checkBackground();
        return true;
      })
      ..addHook(Win.hookResize, (_) {
        resizeWin(win);
        return true;
      })
      ..addHook(Win.hookMaximize, (_) {
        if (win._maximized)
          _hideBelow(win);
        else
          _showBelow(win);
        return true;
      })
      ..addHook(Win.hookRender, (_) {
        final tab = new WinTab(title, icon);
        _cacheWins.add(win);

        if (win.type != WinType.bound) {
          app.tabs.setTab(win, tab);
          win.win.addAction((e) => refreshWinTabs(win), 'mousedown');
          tab.addAction((e) {
            e.preventDefault();
            if (app.disabledNavigation) return;
            if (tab.isActive) {
              tab.inactivate();
              win.minimize();
              checkBackground();
            } else {
              refreshWinTabs(win);
            }
          }, 'mousedown');
        } else {
          win.win_min.remove();
          win.win_max.remove();
        }

        refreshWinTabs(win);
        return true;
      });
    return win;
  }

  void _showBelow(Win win, {bool including = false}) {
    //TODO Maybe _cacheWins will be sorted by default ?
    final List<Win> ordered = new List.from(_cacheWins)
      ..sort((b, a) => a._zIndex.compareTo(b._zIndex));
    final wins = ordered.where((w) => w._zIndex < win._zIndex);
    if (including) win.activate();
    for (final w in wins) {
      w.activate();
      if (w._maximized) break;
    }
  }

  void _hideBelow(Win win) {
    final wins = _cacheWins.where((w) => w._zIndex < win._zIndex);
    for (final w in wins) w.inactivate();
  }

  void checkBackground() {
    for (final w in _cacheWins) {
      if (w.visible) {
        app.tabs.getTab(w).activate();
        w.activate();
        break;
      }
    }
    var has = false;
    _map.forEach((k, v) {
      if (v.isActive) has = true;
    });
    if (!has) app.gadgetsContainer.setStyle({'opacity': '1'});
  }

  Win loadBoundWin({@required String title, String icon}) =>
      loadWindow(title: title, icon: icon, type: WinType.bound);

  void setItem(Win w, _WinC item) => _map_items[w.hashCode.toString()] = item;

  _WinC getItem(Win w) => _map_items[w.hashCode.toString()];

  void refreshWinTabs(Win w) {
    final win = indexResolver(w);
    if (win != null) {
      app.gadgetsContainer.setStyle({'opacity': '0.2'});
      app.desktop.scroll.enabled = false;
      if (win.type != WinType.bound) {
        _cacheWins.forEach((w) => app.tabs.getTab(w)?.inactivate());
        app.tabs.getTab(win)?.activate();
        win.activate();
      }
      win.show();
      final winc = getItem(win);
      if (winc != null) pushUrl(winc.key);
      if (win._maximized) _hideBelow(win);
      win.observer.execHooks(Win.hookFocus);
    } else {
      app.gadgetsContainer.setStyle({'opacity': '1'});
      app.desktop.scroll.enabled = true;
    }
  }

  bool resizeWin(Win win) {
    ScreenType.values
        .forEach((v) => win.win.removeClass(v.toString().split('.').last));
    final scr = app.getDeviceBasedOnWidth(win.win.getWidth());
    win.win.addClass(scr.toString().split('.').last);
    return true;
  }

  bool removeWin(Win win) {
    _cacheWins.removeWhere((w) => w == win);
    final winc = getItem(win);
    if (winc != null) pushUrl('');
    app.tabs.removeTab(win);
    refreshWinTabs(null);
    if (_cacheWins.isNotEmpty) _showBelow(_cacheWins.last, including: true);
    return true;
  }

  void closeAllWins() {
    for (var i = 0; i < _cacheWins.length; i++) _cacheWins[i].close();
  }

  Win indexResolver(Win win) {
    if (win != null) win.setZIndex(zIndexWin + _cacheWins.length + 1);

    final sorter = [];
    final map = <int, Win>{};
    _cacheWins.forEach((w) {
      sorter.add(w._zIndex);
      map[w._zIndex] = w;
    });
    sorter.sort();
    int start = zIndexWin;
    sorter.forEach((v) => map[v].setZIndex(++start));

    final lastB = _cacheWins.lastWhere((w) => w.type == WinType.bound,
        orElse: () => null);
    if (lastB != null)
      app.disableApp(zIndex: lastB._zIndex - 1);
    else
      app.enableApp();

    if (sorter.isNotEmpty) return map[sorter.last];
    return null;
  }

  void initWinLayouts() {
    _cacheWins.forEach((w) {
      if (w._maximized) {
        w
          .._maximized = false
          ..maximize();
      }
    });
  }
}
