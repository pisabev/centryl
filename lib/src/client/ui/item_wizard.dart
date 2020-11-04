part of ui;

class LayoutContainerWizard extends cl.Container {
  cl_gui.Wizard contInner;
  cl.Container contMenu;

  LayoutContainerWizard() : super() {
    contInner = new cl_gui.Wizard();
    contMenu = new cl.Container();

    addRow(contInner);
    addRow(contMenu);
  }
}

abstract class ItemWizard extends ItemBase implements cl_app.Item {
  @Deprecated('Use WinMeta instead')
  Map w;
  cl_app.WinApp wapi;
  cl_app.WinMeta meta;

  LayoutContainerWizard layout;
  cl_action.Menu menu;

  StreamSubscription _formLoad;
  StreamSubscription _valueChange;

  bool listenForChange = false;

  cl_form.Form form = new cl_form.Form();

  static const bool __close_set = false;
  static const bool __answer = false;

  ItemWizard(ap, [id]) : super(ap, id) {
    initLayout();
    setActions();
    setHooks();
    setUI();
    if (id != null && id != 0)
      get();
    else
      init();
  }

  void createLayout() {
    layout = new LayoutContainerWizard();
  }

  void setUI();

  Future init() async {
    await ap.loadExecute(layout, () async {
      await setDefaults();
      setOnChangeSubscription();
    });
  }

  Future setDefaults();

  void initLayout() {
    createLayout();
    wapi = new cl_app.WinApp(ap);
    if (w != null) {
      wapi.load(
          new cl_app.WinMeta()
            ..title = w['title'](_id)
            ..width = w['width']
            ..height = w['height']
            ..icon = w['icon'],
          this);
    } else {
      wapi.load(meta, this);
    }

    menu = new cl_action.Menu(layout.contMenu);
    wapi.win.getContent().append(layout, scrollable: true);
    wapi.render();
  }

  void setActions() {
    menu
      ..add(new cl_action.Button()
        ..setName('back')
        ..setState(false)
        ..setTitle(intl.Back())
        ..setIcon(cl.Icon.chevron_left)
        ..addAction((e) => layout.contInner.prev()))
      ..add(new cl_action.Button()
        ..setName('continue')
        ..setState(false)
        ..setTitle(intl.Continue())
        ..setIcon(cl.Icon.chevron_right)
        ..addAction((e) => layout.contInner.next()))
      ..add(new cl_action.Button()
        ..setName('finish')
        ..setState(false)
        ..setTitle(intl.Finish())
        ..setIcon(cl.Icon.check)
        ..addClass('important')
        ..addAction((e) => save()));
  }

  void setData() {
    if (data_response != null) form.setValue(data_response);
  }

  bool setOnChangeSubscription() {
    void _set([f]) {
      listenForChange = true;
      _valueChange = form.onValueChanged.listen((el) {
        if (listenForChange) setMenuState(true);
      });
    }

    new Future(() {
      if (form.isLoading)
        _formLoad = form.onLoadEnd.listen(_set);
      else
        _set();
    });
    return true;
  }

  void setHooks() {
    addHook(ItemBase.get_after, (_) {
      readData();
      setData();
      setOnChangeSubscription();
      return true;
    });
    addHook(ItemBase.save_before, (_) => checkData());
    addHook(ItemBase.save_before, (_) {
      prepareData();
      return true;
    });
    addHook(ItemBase.save_after, (_) {
      wapi.close();
      return true;
    });
  }

  Future get([cl.CLElementBase loading]) => super.get(loading ?? layout);

  cl_gui.WizardElement createStep(String title, dynamic element) {
    final te = layout.contInner.createStep(title);
    if (element is cl_form.Data) {
      element.onValueChanged.listen((e) {
        if (listenForChange && te.validate != null) setMenuState(true, te);
      });
    }
    te.contentDom.append(element);
    return te;
  }

  bool checkData() {
    final req = form.getNotReady();
    if (req.isNotEmpty) {
      req.forEach((el) => el.contrReady.add(el));
      req.first.focus();
      return false;
    }
    return true;
  }

  void prepareData() {
    data_send = {'id': _id, 'data': form.getValue()};
  }

  void setMenuState(bool way, [cl_gui.WizardElement currentElement]) {
    currentElement ??= layout.contInner.getCurrentStep();
    var valid = false;
    if (currentElement.validate != null) valid = currentElement.validate();
    menu
      ..setState('back', false)
      ..setState('continue', false)
      ..setState('finish', false);
    if (way == false) return;
    if (valid) {
      if (currentElement.isLast())
        menu.setState('finish', true);
      else
        menu.setState('continue', true);
    }
    if (!currentElement.isFirst()) menu.setState('back', true);
  }

  void resetListeners() {
    listenForChange = false;
    if (_formLoad != null) {
      _formLoad.cancel();
      _formLoad = null;
    }
    if (_valueChange != null) {
      _valueChange.cancel();
      _valueChange = null;
    }
  }

  void readData() {
    resetListeners();
    if (data_response != null && data_response['id'] != null)
      setId(data_response['id']);
  }
}
