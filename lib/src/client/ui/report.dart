part of ui;

class _LayoutContainerReport extends cl.Container {
  late cl.Container contLeft,
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

abstract class Report<C extends cl_app.Client> implements cl_app.Item<C> {
  UrlPattern? contr_get, contr_print, contr_csv;

  late cl_app.Application<C> ap;
  late cl_app.WinMeta meta;
  late cl_app.WinApp<C> wapi;
  late _LayoutContainerReport layout;
  late cl_action.Menu menuLeftBottom, menuRightTop, menuRightBottom;

  late GridList gridReport;
  cl_form.Form form = new cl_form.Form();
  cl_util.Observer observer = new cl_util.Observer();
  late Map params;
  Map? data_response;

  Report(this.ap) {
    try {
      initLayout();
      setActions();
      setHooks();
      setFilter();
    } catch (e, s) {
      cl.logging.severe(runtimeType.toString(), e, s);
    }
  }

  void createLayout() {
    layout = new _LayoutContainerReport();
  }

  void initLayout() {
    createLayout();
    wapi = new cl_app.WinApp(ap)..load(meta, this);
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
        ..addAction((_) => printData()));
    }
    if (contr_csv != null) {
      menuLeftBottom.add(new cl_action.Button()
        ..disable()
        ..setTip(intl.Export(), 'top')
        ..setName($BaseConsts.export)
        ..setIcon(cl.Icon.file_excel)
        ..addAction((_) => csvData()));
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

  void printData() => cl_util.printUrl(
      ap.baseurl + contr_print!.reverse([window.btoa(json.encode(params))]),
      layout);

  void csvData() => ap.download(contr_csv!.reverse([]), params, layout);

  void setFilter();

  void setParamsGet() {
    params = {
      $BaseConsts.order: gridReport.grid.order?.toMap(),
      $BaseConsts.filter: form.getValue()
    };
  }

  Future getData([cl.CLElementBase? loading]) async {
    await ap.loadExecute(loading, () async {
      if (await observer.execHooksAsync(ItemBase.get_before)) {
        data_response =
            await ap.serverCall<Map>(contr_get!.reverse([]), params, layout);
        await observer.execHooksAsync(ItemBase.get_after);
      }
    });
  }

  void setGrid(GridList grid) {
    gridReport.gridCont.remove();
    gridReport = grid;
    layout.contRightInner.addRow(gridReport.gridCont..auto = true);
    gridReport.gridCont.initLayout();
    gridReport.grid.addHookOrder((_) {
      getData();
      return true;
    });
  }

  void setData() {
    gridReport.grid.empty();
    if (data_response == null ||
        data_response![$BaseConsts.result] == null ||
        data_response![$BaseConsts.result].isEmpty) {
      gridReport.gridCont.hide();
      return;
    }
    gridReport.gridCont.show();
    menuLeftBottom[$BaseConsts.print]?.enable();
    menuLeftBottom[$BaseConsts.export]?.enable();
    gridReport.grid.renderIt(data_response![$BaseConsts.result]);
  }

  void addHook(String scope, cl_util.ObserverFunction func,
      [bool first = false]) {
    observer.addHook(scope, func, first);
  }
}
