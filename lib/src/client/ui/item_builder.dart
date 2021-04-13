part of ui;

class ItemBuilderContainerBase extends cl.Container {
  late cl.Container contMenu;
  late cl.Container contInner;

  ItemBuilderContainerBase() {
    createDom();
  }

  void createDom() {
    contMenu = new cl.Container();
    contInner = new cl.Container()..auto = true;

    addRow(contInner);
    addRow(contMenu);
  }

  void reset() {}
}

class ItemBuilderContainer extends ItemBuilderContainerBase {
  covariant late cl_gui.TabContainer contInner;
  bool listenForChange = false;

  void createDom() {
    contMenu = new cl.Container();
    contInner = new cl_gui.TabContainer()..auto = true;

    addRow(contInner);
    addRow(contMenu);
  }

  void reset() {
    contInner.clearTabs();
  }

  cl_gui.TabElement createTab(String title, dynamic element,
      {bool scrollable = true}) {
    final te = contInner.createTab(title);
    if (element is cl_form.Data) {
      element.onValueChanged.listen((e) {
        if (listenForChange && contInner.isVisible(te)) te.changed();
      });
    }
    te.append(element, scrollable: scrollable);
    return te;
  }
}

class _LayoutContainerOp extends ItemBuilderContainer {
  late cl.Container contMenu, contTop, contTopLeft, contTopRight;
  late cl_gui.TabContainer contInner;

  void createDom() {
    contTop = new cl.Container();
    contInner = new cl_gui.TabContainer()..auto = true;
    contMenu = new cl.Container();

    contTop
      ..addCol(contTopLeft = new cl.Container()..auto = true)
      ..addCol(contTopRight = new cl.Container()..auto = true);

    addRow(contTop);
    addRow(contInner);
    addRow(contMenu);
  }
}

abstract class ItemBuilderBase<C extends cl_app.Client> extends ItemBase<C>
    implements cl_app.Item<C> {
  late cl_app.WinMeta meta;
  late cl_app.WinApp<C> wapi;

  late ItemBuilderContainerBase layout;
  final StreamController<bool> _contr = new StreamController.broadcast();
  late cl_action.Menu menu;

  bool _listenForChange = false;
  bool isDirty = false;

  cl_form.Form form = new cl_form.Form();

  bool __close_set = false;
  bool __answer = false;

  ItemBuilderBase(ap, [id]) : super(ap, id) {
    try {
      initLayout();
      setActions();
      setHooks();
      setUI();
      form.onLoadStart.listen((e) {
        setMenuState(false);
        late StreamSubscription _loadEnd;
        _loadEnd = form.onLoadEnd.listen((e) {
          if (isDirty) setMenuState(true);
          _loadEnd.cancel();
        });
      });
      form.onValueChanged.listen((el) {
        if (listenForChange) {
          setDirtyState(true);
          setMenuState(true);
        }
      });
    } catch (e, s) {
      cl.logging.severe(runtimeType.toString(), e, s);
    }
    form.onWarning.listen((el) {
      menu['save_true']?.removeWarnings();
      menu['save']?.removeWarnings();
      form.getWarnings().forEach((dw) {
        menu['save_true']?.setWarning(dw, show: false);
        menu['save']?.setWarning(dw, show: false);
      });
    });
    if (id != null && id != 0)
      get();
    else
      init();
  }

  set listenForChange(bool v) => _listenForChange = v;

  bool get listenForChange => _listenForChange;

  Stream<bool> get onListenForChange => _contr.stream;

  void createLayout() {
    layout = new ItemBuilderContainerBase();
  }

  void setUI();

  Future init() async {
    await ap.loadExecute(layout, () async {
      await setDefaults();
      await setOnChangeSubscription();
      await _setTitle();
    });
  }

  Future setDefaults();

  Future<void> _setTitle() async {
    if (meta.title != null)
      wapi.setTitle(meta.getTitle(getId()));
    else
      wapi.setTitle(await getTitle());
  }

  void initLayout() {
    createLayout();
    wapi = new cl_app.WinApp(ap);
    wapi.load(meta, this);
    menu = new cl_action.Menu(layout.contMenu..addClass('shadowed'));
    wapi.win.getContent().append(layout, scrollable: true);
    wapi.render();
    final action =
        new cl_util.KeyAction(cl_util.KeyAction.CTRL_S, () => saveIt(false));
    wapi.win.addKeyAction(action);
  }

  void setActions() {
    menu
      ..add(new cl_action.Button()
        ..setName('save_true')
        ..setState(false)
        ..setTitle(intl.Save_and_close())
        ..setIcon(cl.Icon.save)
        ..addClass('important')
        ..addAction((e) => saveIt(true)))
      ..add(new cl_action.Button()
        ..setName('save')
        ..setState(false)
        ..setTitle(intl.Save())
        ..setIcon(cl.Icon.save)
        ..addClass('important')
        ..addAction((e) => saveIt(false)))
      ..add(new cl_action.Button()
        ..setName('clear')
        ..setState(false)
        ..setTitle(intl.Refresh())
        ..setIcon(cl.Icon.sync)
        ..addAction((e) => get()));
    if (contr_del != null)
      menu.add(new cl_action.Button()
        ..setName('del')
        ..setState(false)
        ..setTitle(intl.Delete())
        ..setIcon(cl.Icon.delete)
        ..setStyle({'margin-left': 'auto'})
        ..addClass('warning')
        ..addAction((e) => del()));
  }

  Future setData() async {
    if (data_response != null) form.setValue(data_response);
  }

  Future setOnChangeSubscription() => new Future(() {
        listenForChange = true;
        _contr.add(true);
      });

  FutureOr<String> getTitle() => '';

  void setHooks() {
    addHook(ItemBase.get_after, (_) async {
      readData();
      layout.reset();
      await setData();
      await setOnChangeSubscription();
      setMenuState(false);
      await _setTitle();
      if (form.isLoading) {
        final completer = new Completer<bool>();
        late StreamSubscription listen;
        listen = form.onLoadEnd.listen((e) {
          completer.complete(true);
          listen.cancel();
        });
        return completer.future;
      } else
        return true;
    });
    addHook(ItemBase.save_before, (_) => checkData());
    addHook(ItemBase.save_before, (_) {
      prepareData();
      setMenuState(false);
      return true;
    });
    addHook(ItemBase.save_after, (_) {
      close(__close_set);
      return true;
    });
    addHook(ItemBase.del_before, (_) => ask(intl.Delete_warning(), del));
    addHook(ItemBase.del_after, (_) {
      __close_set = true;
      data_response = null;
      close(__close_set);
      return true;
    });
    wapi.win.observer
      ..addHook(
          'close',
          (_) => isDirty ? ask(intl.Close_warning(), wapi.win.close) : !isDirty,
          true)
      ..addHook('close', (_) {
        ap.preventRefresh = false;
        return true;
      });
  }

  Future get([cl.CLElementBase? loading]) => super.get(loading ?? layout);

  Future save([cl.CLElementBase? loading]) => super.save(loading ?? layout);

  bool ask(String message, Function call) {
    if (__answer) {
      __answer = false;
      return true;
    }
    final cont = new cl.Container()
      ..append(new ParagraphElement()..text = message)
      ..addClass('center');
    final w = new cl_app.Questioner(ap, cont)
      ..onYes = () {
        __answer = true;
        call();
        return true;
      }
      ..render();
    w.noDom
      ..addClass('important')
      ..focus();
    return false;
  }

  bool checkData() {
    if (!form.isReady()) {
      final req = form.getNotReady();
      if (req.isNotEmpty) {
        req.forEach((el) {
          el.contrReady.add(el);
        });
        final first = req.first;
        if (first is cl_form.DataElement) {
          final parent = cl_util.getScrollParent(first.dom);
          if (parent != null)
            parent.parent?.scrollTop = first.dom.offsetTop - 50;
        }
      }
      menu['save']?.showWarnings(const Duration(seconds: 1));
      return false;
    }
    return true;
  }

  void prepareData() {
    data_send = {'id': _id, 'data': form.getValue()};
  }

  void setMenuState(bool way) {
    if (menu.indexOfElements.isNotEmpty) {
      menu.indexOfElements.forEach((but) => but.setState(way));
      menu['clear']?.setState(!(_id == null || _id == 0));
      if (contr_del != null) menu['del']?.setState(!(_id == null || _id == 0));
    }
  }

  void saveIt(bool way) {
    __close_set = way;
    if (isDirty) save();
  }

  void close(bool way) {
    if (data_response != null && data_response['id'] != null)
      setId(data_response['id']);
    else
      setId(null);
    if (way) {
      resetListeners();
      wapi.close();
    } else {
      get();
    }
  }

  void setDirtyState(bool state) {
    isDirty = state;
    ap.preventRefresh = state;
    __answer = false;
  }

  void resetListeners() {
    listenForChange = false;
    _contr.add(false);
    setDirtyState(false);
  }

  void readData() {
    resetListeners();
    if (data_response != null && data_response['id'] != null)
      setId(data_response['id']);
  }
}

abstract class ItemBuilder<C extends cl_app.Client> extends ItemBuilderBase<C> {
  covariant late ItemBuilderContainer layout;

  ItemBuilder(ap, [id]) : super(ap, id);

  void createLayout() {
    layout = new ItemBuilderContainer();
  }

  set listenForChange(bool v) {
    _listenForChange = v;
    layout.listenForChange = v;
  }

  cl_gui.TabElement createTab(String title, dynamic element,
          {bool scrollable = true}) =>
      layout.createTab(title, element, scrollable: scrollable);
}

abstract class ItemOperation<C extends cl_app.Client> extends ItemBuilder<C> {
  covariant late _LayoutContainerOp layout;

  ItemOperation(ap, [id]) : super(ap, id);

  void createLayout() {
    layout = new _LayoutContainerOp();
  }
}
