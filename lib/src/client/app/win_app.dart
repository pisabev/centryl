part of app;

class WinMeta {
  dynamic title;
  String? icon;
  int width = 0;
  int height = 0;
  int left = 0;
  int top = 0;
  String? type;

  String getTitle([Object? param]) => title is Function ? title(param) : title;
}

class Item<C extends Client> {
  WinApp<C>? wapi;
}

class WinApp<C extends Client> {
  Application<C> app;
  late WinMeta meta;
  late Win win;

  WinApp(this.app);

  void load(WinMeta meta, Object obj, [int? startZIndex]) {
    this.meta = meta;
    win = (meta.type == 'bound')
        ? app.winmanager.loadBoundWin(title: meta.getTitle(), icon: meta.icon)
        : app.winmanager.loadWindow(title: meta.getTitle(), icon: meta.icon);
    win.addKeyAction(new utils.KeyAction(utils.KeyAction.ESC, win.close));
    win.observer.addHook('close', (_) {
      clear(obj);
      return true;
    });
  }

  void addFocusHook(utils.ObserverFunction func) {
    win.observer.addHook(Win.hookFocus, func);
  }

  void addLayoutHook(utils.ObserverFunction func) {
    win.observer.addHook(Win.hookLayout, func);
  }

  void addCloseHook(utils.ObserverFunction func) {
    win.observer.addHook(Win.hookClose, func);
  }

  void setTitle(String title) {
    win.setTitle(title);
    app.tabs.getTab(win)?.setTitle(title);
  }

  void render() {
    if (app.settings.fullWindowMode && meta.type != 'bound')
      win.render();
    else
      win.render(meta.width, meta.height, meta.left, meta.top);
  }

  void close() {
    win.close();
  }

  void clear(Object obj) {
    app.winmanager.registry.remove(obj);
  }
}
