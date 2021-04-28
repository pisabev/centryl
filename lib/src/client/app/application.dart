part of app;

class AppSettings {
  String baseurl = '/';
  bool menuDefaultOpen = true;
  bool desktopIcons = false;
  int menuStyle = 1;
  bool menuHideOnAction = false;
  bool fullWindowMode = false;
}

enum ScreenType { phone, tablet, desktop, large }

class Application<C extends Client> {
  late AppSettings settings;

  late CLElement container;

  late CLElement page, fieldLeft, fieldTop, fieldRight, menuBut;
  late Container desktop, gadgetsContainer, addons;

  late Notify notify;
  late MessageBus messagebus;
  late IconContainer iconContainer;
  List<GadgetContainer> gadgetContainers = [];
  late WinManager winmanager;
  late C client;
  late Menu menu;
  late WinTabContainer tabs;

  bool disabledNavigation = false;
  bool preventRefresh = false;

  dynamic asideContext;

  static const String _appServerException = 'AppServerException';
  static const String _appWorkException = 'AppWorkException';
  static const String _appPermissionException = 'AppPermissionException';

  late Future<T> Function<T>(String, Map) _server_call;
  late Future<Map> Function(String, Map) _download_call;

  bool fullScreen = false;

  set server_call(Future<T> Function<T>(String, Map) c) => _server_call = c;

  set download_call(Future<Map> Function(String, Map) c) => _download_call = c;

  Application({CLElement? container, AppSettings? settings}) {
    this.settings = settings ?? new AppSettings();
    Icon.BASEURL = settings!.baseurl;
    Icon.ICON_FLAG_PATH = '${settings.baseurl}packages/centryl/images/flags/';
    onLoadStart();
    this.container = container ?? new CLElement(document.body);
    createDom();
    init();
    initLayout();
  }

  String get baseurl => settings.baseurl;

  void createDom() {
    page = new CLElement(new Element.tag('main'))..addClass('ui-page');
    fieldTop = new CLElement(new Element.tag('nav'))..addClass('ui-top');
    fieldLeft = new CLElement(new Element.tag('nav'))..addClass('ui-left');
    fieldRight = new CLElement(new Element.tag('aside'))..addClass('ui-right');
    final section = new CLElement(new Element.tag('section'));

    desktop = new Container()..addClass('ui-desktop');

    section.append(desktop);

    page
      ..append(fieldTop)
      ..append(fieldLeft)
      ..append(section)
      ..append(fieldRight);

    gadgetsContainer = new Container()..addClass('ui-gadgets');
    addons = new Container()..addClass('ui-addons');
    tabs = new WinTabContainer(this);

    menuBut = new CLElement(new AnchorElement())
      ..append(new Icon(Icon.menu).dom)
      ..addAction((e) {
        toggleMenu();
      })
      ..addClass('ui-menu-button');

    desktop.append(gadgetsContainer, scrollable: true);

    fieldTop..append(menuBut)..append(tabs)..append(addons);

    container.append(page.dom);
  }

  void init() {
    notify = new Notify(this);
    messagebus = new MessageBus();
    menu = new Menu(this);
    winmanager = new WinManager(this);
  }

  ScreenType getDeviceBasedOnWidth(num width) {
    ScreenType label;
    if (width < 400)
      label = ScreenType.phone;
    else if (width < 800)
      label = ScreenType.tablet;
    else if (width < 1000)
      label = ScreenType.desktop;
    else
      label = ScreenType.large;
    return label;
  }

  void initLayout() {
    final label = getDeviceBasedOnWidth(window.innerWidth ?? 0);
    document.body!.classes = [label.toString().split('.').last];
    if (label == ScreenType.phone || !settings.menuDefaultOpen) {
      settings.menuHideOnAction = true;
      menuHide();
    } else
      winmanager.initWinLayouts();
  }

  void storagePut(String key, Map<String, dynamic>? value) =>
      window.localStorage[key] = json.encode(value);

  Map<String, dynamic>? storageFetch(String key) {
    try {
      return json.decode(window.localStorage[key]!);
    } catch (e) {}
    return null;
  }

  void reboot([Duration? delay]) {
    if (delay != null) {
      final r = new NotificationMessage(NotificationMessage.error)
        ..persist = false
        ..action = (() => window.location.reload())
        ..textFunction = (o) {
          int i = delay.inSeconds;
          void mess() => o.setText(intl.Browser_refresh(i--));
          new Timer.periodic(const Duration(seconds: 1), (_) => mess());
          mess();
          new Timer(delay, () => window.location.reload());
        };
      notify.add(r);
    } else {
      window.location.reload();
    }
  }

  void toggleMenu() {
    page.toggleClass('menu-hide');
    if (!page.existClass('menu-hide'))
      new Timer(const Duration(milliseconds: 200), winmanager.initWinLayouts);
    else
      winmanager.initWinLayouts();
  }

  void onInactive(
      Duration duration, void Function() onInactive, void Function() onActive) {
    Timer t = new Timer(duration, onInactive);
    final _reset = () {
      t.cancel();
      t = new Timer(duration, onInactive);
      onActive();
    };
    document.onMouseMove.listen((event) => _reset());
    document.onMouseDown.listen((event) => _reset());
    document.onKeyPress.listen((event) => _reset());
    document.onTouchMove.listen((event) => _reset());
  }

  void menuHide() {
    page.addClass('menu-hide');
    winmanager.initWinLayouts();
  }

  void menuShow() {
    page.removeClass('menu-hide');
    new Timer(const Duration(milliseconds: 200), winmanager.initWinLayouts);
  }

  bool get asideIsVisible => page.existClass('aside-show');

  void asideHide() {
    if (!asideIsVisible) return;
    page.removeClass('aside-show');
  }

  void asideShow() {
    if (asideIsVisible) return;
    page.addClass('aside-show');
  }

  bool toggleAside(Object context) {
    if (asideContext == context) {
      asideHide();
      asideContext = null;
      return false;
    }

    asideContext = context;
    if (!asideIsVisible) asideShow();
    return true;
  }

  void done() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((rec) {
      if (rec.level == Level.SEVERE) {
        if (rec.error != null &&
            (rec.error.toString().contains(_appServerException) ||
                rec.error.toString().contains(_appPermissionException) ||
                rec.error.toString().contains(_appWorkException))) return;
        window.console.error('${rec.error.toString()}'
            '\n\n${rec.stackTrace?.toString()}');
      } else
        print(rec.message);
    });

    client.apps.forEach((app) => app.init(this));
    addons
      ..append(notify.messageDom())
      ..append(new action.Button()
        ..setIcon(Icon.fullscreen)
        ..addAction((e) => utils.fullscreenWorkaround(fullScreen = !fullScreen))
        ..setTip(intl.Fullscreen(), 'bottom'))
      ..append(new Clock());
    if (menu.mainElements.isNotEmpty) menu.render();

    if (settings.desktopIcons) {
      iconContainer = new IconContainer();
      menu.getDesktopIcons().forEach(iconContainer.addIcon);
      gadgetsContainer.addRow(iconContainer);
    }

    gadgetContainers.forEach((cont) {
      gadgetsContainer.addRow(cont);
      cont
        ..ap = this
        ..load();
    });

    notify.init();

    window.onResize.listen((e) => initLayout());
    //document.body.onContextMenu.listen((e) => e.preventDefault());
    window.onPopState.listen((p) {
      if (p.state != null) winmanager.run(p.state);
    });
    final subpath = window.location.pathname!.replaceFirst(baseurl, '');
    if (subpath.isNotEmpty) winmanager.run(subpath);

    onLoadEnd();

    window.onBeforeUnload.listen((e) {
      if (preventRefresh)
        (e as BeforeUnloadEvent).returnValue = 'Unsaved Data!';
    });
  }

  void setAbout(String icon, String? text) {
    fieldLeft.append(new CLElement(new AnchorElement())
      ..setClass('brand')
      ..setStyle({'background-image': 'url($icon)'})
      ..addAction((e) {
        final cont = new Container()
          ..addClass('ui-row')
          ..auto = true
          ..append(new ParagraphElement()..text = text);
        new Dialog(this, cont)
          ..title = 'Centryl v2.0'
          ..render();
      }));
  }

  void setClient(Client client) {
    this.client = client as C;
  }

  void setMenu(List<MenuElement> data) => menu.setMenu(data);

  void addRoute(Route route) => winmanager.registry.addRoute(route);

  T run<T extends Item<Client>>(String key, [List? addParams]) =>
      winmanager.run(key, addParams) as T;

  void error(dynamic o, [String stack = '']) {
    if (o is ServerError) {
      final cont = new Container()
        ..addClass('ui-row')
        ..auto = true
        ..append(new ParagraphElement()
          ..text = o.message
          ..classes.add('error-title'));
      if (o.details != null) {
        cont.append(new ParagraphElement()
          ..text = o.details
          ..classes.add('error-details'));
      }
      new Confirmer(this, cont)
        ..title = o.title
        ..icon = o.icon
        ..render();
    } else {
      final cont = new Container()
        ..addClass('ui-row')
        ..auto = true
        ..append(new ParagraphElement()..text = o.toString());
      new Confirmer(this, cont)
        ..title = intl.Error()
        ..icon = Icon.error
        ..render();
    }
  }

  void warning(dynamic o, [String stack = '']) {
    final cont = new Container()
      ..addClass('ui-row')
      ..auto = true
      ..append(new ParagraphElement()..text = o.toString());
    new Dialog(this, cont)
      ..title = intl.Warning()
      ..icon = Icon.warning
      ..render();
  }

  Future<T?> serverCall<T>(String contr, dynamic data,
      [CLElementBase? loading]) async {
    final params = (data == null || data is Map) ? data : data.toJson();
    final response =
        await loadExecute(loading, () => _server_call(contr, params));
    if (response['status'] != null) {
      final er = new ServerError(response['status']);
      if (response['status']['message'] == 'Not Found') {
        winmanager.closeAllWins();
        return null;
      } else if (response['status']['type'] == 'permission') {
        error(er);
        throw new Exception(_appPermissionException);
      } else if (response['status']['type'] == 'work_exception') {
        error(er);
        throw new Exception(_appWorkException);
      } else {
        notify.add(new NotificationMessage(NotificationMessage.error)
          ..persist = false
          ..event = 'error'
          ..date = new DateTime.now()
          ..text = er.message
          ..action = () => error(er));
        error(er);
        throw new Exception(_appServerException);
      }
    }
    return response['data'];
  }

  Future<void> download(String contr, dynamic data,
      [CLElementBase? loading]) async {
    final params = (data == null || data is Map) ? data : data.toJson();
    final response =
        await loadExecute(loading, () => _download_call(contr, params));
    if (response != null && response['status'] != null) {
      final er = new ServerError(response['status']);
      if (response['status']['message'] == 'Not Found') {
        winmanager.closeAllWins();
        return;
      } else if (response['status']['type'] == 'permission') {
        error(er);
        throw new Exception(_appPermissionException);
      } else if (response['status']['type'] == 'work_exception') {
        error(er);
        throw new Exception(_appWorkException);
      } else {
        notify.add(new NotificationMessage(NotificationMessage.error)
          ..persist = false
          ..event = 'error'
          ..date = new DateTime.now()
          ..text = er.message
          ..action = () => error(er));
        error(er);
        throw new Exception(_appServerException);
      }
    }
  }

  Future<T?> loadExecute<T>(CLElementBase? loadElement, Future<T> Function() f,
      [int delay = 200]) async {
    T? response;
    try {
      if (loadElement == null) return f();
      final LoadElement loadEl = new LoadElement(loadElement, delay);
      try {
        response = await f();
      } finally {
        loadEl.remove();
      }
    } catch (e, s) {
      logging.severe(runtimeType.toString(), e, s);
    }
    return response;
  }

  set on_server_call(Stream<List> v) => messagebus._hook(v);

  MessageBus get onServerCall => messagebus;

  void disableApp(
      {int zIndex = 900, CLElement<Element>? cont, String? message}) {
    disabledNavigation = true;
    final el = document.getElementById('ui-app-disabled');
    if (el != null) {
      new CLElement(el).setStyle({'z-index': zIndex.toString()});
      return;
    }
    final blur = new CLElement(new DivElement())
      ..addClass('overlay-disable')
      ..dom.id = 'ui-app-disabled';
    cont ??= container;
    blur
      ..appendTo(cont)
      ..setStyle({'z-index': zIndex.toString()});
    new Timer(const Duration(milliseconds: 10), () => blur.addClass('active'));
    if (message != null) {
      final mes = new CLElement(new DivElement())
        ..addClass('overlay-disable-message')
        ..dom.id = 'ui-app-disabled-message'
        ..append(new CLElement(new DivElement())..setText(message))
        ..appendTo(cont)
        ..setStyle({'z-index': (zIndex + 1).toString()});
      new Timer(const Duration(milliseconds: 10), () => mes.addClass('active'));
      page.addClass('blurred');
    }
  }

  void enableApp() {
    disabledNavigation = false;
    page.removeClass('blurred');
    document.getElementById('ui-app-disabled')?.remove();
    document.getElementById('ui-app-disabled-message')?.remove();
  }

  void onLoadStart() {
    final sp = new DivElement()
      ..id = 'app-loader'
      ..classes.add('spinner')
      ..append(new DivElement()..classes.add('double-bounce1'))
      ..append(new DivElement()..classes.add('double-bounce2'));
    document.body!.append(sp);
  }

  void onLoadEnd() {
    document.getElementById('app-loader')!.remove();
    page.setStyle({'opacity': '1'});
  }
}

class ServerError {
  String? details;
  String? type;
  String? message;

  ServerError(o) {
    details = o['details'];
    type = o['type'];
    message = o['message'];
  }

  String? get icon {
    if (type == 'error')
      return Icon.error;
    else if (type == 'exception')
      return Icon.error;
    else if (type == 'work_exception')
      return Icon.warning;
    else if (type == 'permission') return Icon.lock;
    return null;
  }

  String? get title {
    if (type == 'error')
      return intl.Error();
    else if (type == 'exception')
      return intl.Exception();
    else if (type == 'work_exception')
      return intl.Work_exception();
    else if (type == 'permission') return intl.Permission();
    return null;
  }
}
