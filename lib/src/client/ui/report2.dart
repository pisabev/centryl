part of ui;

class _LayoutContainerReport extends cl.Container {
  cl.Container contLeft,
      contLeftInner,
      contLeftBottom,
      contRight,
      contRightTop,
      contRightInner,
      contRightBottom;

  _LayoutContainerReport() : super() {
    contLeft = new cl.Container()
      ..setWidth(new cl.Dimension.px(300))
      ..addClass('section');
    contRight = new cl.Container()..auto = true;

    contLeftInner = new cl.Container()..auto = true;
    contLeftBottom = new cl.Container();

    contRightTop = new cl.Container();
    contRightInner = new cl.Container()..auto = true;
    contRightBottom = new cl.Container();

    contLeft..addRow(contLeftInner)..addRow(contLeftBottom);

    contRight
      ..addRow(contRightTop)
      ..addRow(contRightInner)
      ..addRow(contRightBottom);

    addCol(contLeft);
    addCol(contRight);
  }
}

abstract class Report2<C extends cl_app.Client> implements cl_app.Item<C> {
  dynamic lang_select;
  UrlPattern contr_get, contr_print, contr_csv;

  cl_app.Application<C> ap;
  @Deprecated('Use WinMeta instead')
  Map w;
  cl_app.WinMeta meta;
  cl_app.WinApp<C> wapi;
  _LayoutContainerReport layout;
  cl_action.Menu menuLeftBottom, menuRightTop, menuRightBottom;

  cl_form.GridListContainer gridCont;
  cl_form.GridList grid;
  cl_form.Form form = new cl_form.Form();
  cl_util.Observer observer = new cl_util.Observer();
  Map params;
  Map data_response;

  Report2(this.ap) {
    try {
      initLayout();
      initGrid();
      setActions();
      setHooks();
      setFilter();
      initFooter();
    } catch (e, s) {
      cl.logging.severe(runtimeType.toString(), e, s);
    }
  }

  void createLayout() {
    layout = new _LayoutContainerReport();
  }

  void initLayout() {
    createLayout();
    wapi = new cl_app.WinApp(ap);
    if (w != null) {
      wapi.load(
          new cl_app.WinMeta()
            ..title = w['title']
            ..width = w['width']
            ..height = w['height']
            ..icon = w['icon'],
          this);
    } else {
      wapi.load(meta, this);
    }
    menuLeftBottom = new cl_action.Menu(layout.contLeftBottom);
    wapi.win.getContent().append(layout, scrollable: true);
    wapi.render();
  }

  void setActions() {
    menuLeftBottom.add(new cl_action.Button()
      ..setTitle(intl.Generate())
      ..addClass('important')
      ..setIcon(cl.Icon.visibility)
      ..setStyle({'margin-right': 'auto'})
      ..addAction((e) => getData()));
    if (contr_print != null) {
      menuLeftBottom.add(new cl_action.Button()
        ..disable()
        ..setTip(intl.Print(), 'top')
        ..setName($BaseConsts.print)
        ..setIcon(cl.Icon.print)
        ..addAction(printData));
    }
    if (contr_csv != null) {
      menuLeftBottom.add(new cl_action.Button()
        ..disable()
        ..setTip(intl.Export(), 'top')
        ..setName($BaseConsts.export)
        ..setIcon(cl.Icon.file_excel)
        ..addAction(csvData));
    }
  }

  void setHooks() {
    addHook(ItemBase.get_after, (_) {
      setData();
      return true;
    });
    addHook(ItemBase.get_before, (_) => checkData());
    addHook(ItemBase.get_before, (_) {
      setParamsGet();
      return true;
    });
  }

  bool checkData() {
    if (!form.isReady()) {
      final req = form.getNotReady();
      if (req.isNotEmpty) req.forEach((el) => el.contrReady.add(el));
      return false;
    }
    return true;
  }

  void printer(dynamic contr) => cl_util
      .printUrl(ap.baseurl + contr.reverse([window.btoa(json.encode(params))]));

  void printData([_]) => printer(contr_print);

  void csvData([_]) => ap.loadExecute(
      ap.desktop, () => ap.download(contr_csv.reverse([]), params));

  void initGrid() {
    grid = new cl_form.GridList(new cl_form.RenderBuffered());
    gridCont =
        new cl_form.GridListContainer(grid, auto: true, fixedFooter: true);

    final order = initOrder();
    if (order != null && order.length == 2)
      grid.setOrder(new cl_form.GridOrder(order[0], order[1]));

    grid
      ..initGridHeader(initHeader())
      ..addHookRow(initRow)
      ..addHookOrder((_) {
        getData();
        return true;
      });

    layout.contRightInner.addRow(gridCont..auto = true);
    gridCont.initLayout();
  }

  bool initRow(TableRowElement row, Map obj) {
    customRow(row, obj);
    return true;
  }

  List<cl_form.GridColumn> initHeader();

  void initFooter() {}

  void setFooter(Map data) {}

  void setFilter();

  void customRow(TableRowElement row, Map data) {}

  void setParamsGet() {
    params = {
      $BaseConsts.language_id: lang_select?.getValue(),
      $BaseConsts.order: grid.order?.toMap(),
      $BaseConsts.filter: form.getValue()
    };
  }

  List initOrder() => [];

  Future getData([cl.CLElementBase loading]) async {
    await ap.loadExecute(loading, () async {
      if (await observer.execHooksAsync(ItemBase.get_before)) {
        data_response =
            await ap.serverCall<Map>(contr_get.reverse([]), params, layout);
        await observer.execHooksAsync(ItemBase.get_after);
      }
    });
  }

  void setData() {
    grid.empty();
    if (data_response == null ||
        data_response[$BaseConsts.result] == null ||
        data_response[$BaseConsts.result].isEmpty) {
      gridCont.hide();
      return;
    }
    gridCont.show();
    menuLeftBottom[$BaseConsts.print]?.enable();
    menuLeftBottom[$BaseConsts.export]?.enable();
    setFooter(data_response);
    grid.renderIt(data_response[$BaseConsts.result]);
  }

  void addHook(String scope, cl_util.ObserverFunction func,
      [bool first = false]) {
    observer.addHook(scope, func, first);
  }
}
