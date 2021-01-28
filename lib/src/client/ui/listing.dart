part of ui;

class ListingContainerBase extends cl.Container {
  cl.Container contMenu, contMiddle, contBottom;
}

class ListingContainer extends ListingContainerBase {
  ListingContainer() : super() {
    contMenu = new cl.Container();
    contMiddle = new cl.Container()..auto = true;
    contBottom = new cl.Container();

    addRow(contMenu);
    addRow(contMiddle);
    addRow(contBottom);
  }
}

class GridList {
  cl_form.GridListContainer gridCont;
  cl_form.GridList grid;

  GridList(
      {List<cl_form.GridColumn> headers,
      cl_form.GridOrder initOrder,
      bool Function(TableRowElement row, Map data) customRow,
      bool Function(TableRowElement row, Map data) customRowAfter,
      FutureOr<bool> Function(dynamic) hookOrder}) {
    grid = new cl_form.GridList(new cl_form.RenderBuffered());
    gridCont =
        new cl_form.GridListContainer(grid, auto: true, fixedFooter: true);

    grid
      ..initGridHeader(headers)
      ..addHookRow(customRow);

    if (initOrder != null) grid.setOrder(initOrder);
    if (customRowAfter != null) grid.addHookRowAfter(customRowAfter);
    if (hookOrder != null) grid.addHookOrder(hookOrder);
  }
}

abstract class Listing<C extends cl_app.Client> implements cl_app.Item<C> {
  static const String MODE_LIST = 'list';
  static const String MODE_MONITOR = 'monitor';
  static const String MODE_CHOOSE = 'choose';
  static const String $del = 'del';
  static const String $print = 'print';

  static String get get_after => $BaseConsts.get_after;

  static String get del_before => $BaseConsts.del_before;

  static String get del_after => $BaseConsts.del_after;

  static String get print_before => $BaseConsts.print_before;

  dynamic lang_select;

  UrlPattern contr_get, contr_del, contr_print, contr_pdf;

  cl_app.Application<C> ap;
  cl_app.WinMeta meta;
  cl_app.WinApp<C> wapi;
  ListingContainer layout;
  Expando _exp;

  cl_form.Form form;
  cl_action.Menu menu;
  GridList gridList;
  cl_util.Observer observer;
  Map params;
  dynamic data_response;
  cl_form.Check m_check;
  cl_form.GridOrder order;
  Set<cl_form.Check> chks = {};
  Set<Object> chks_set = {};
  Set<Object> _chks_set_tmp = {};
  cl_form.Paginator paginator;

  bool fixedFooter = false;
  bool __answer = false;
  bool useCache;
  final Map<int, TableRowElement> _chk_to_row = {};

  Debouncer debouncer = new Debouncer(const Duration(milliseconds: 200));
  Set<Object> stream_changed_ids = {};

  String mode, key, key_click;

  Listing(this.ap, {bool autoload = true, this.order, this.useCache = false}) {
    observer = new cl_util.Observer();
    form = new cl_form.Form();
    try {
      initLayout();
      initWinListener();
      initGrid();
      setActions();
      setHooks();
      setPaginator();
    } catch (e, s) {
      cl.logging.severe(runtimeType.toString(), e, s);
    }
    if (useCache) {
      final cache = ap.storageFetch(runtimeType.toString());
      if (cache != null) form.setValue(cache);
    }
    if (autoload) getData();
  }

  void createLayout() {
    layout = new ListingContainer();
  }

  void initLayout() {
    createLayout();
    wapi = new cl_app.WinApp(ap)..load(meta, this);
    menu = new cl_action.Menu(layout.contMenu);
    wapi.win.getContent().append(layout, scrollable: true);
    wapi.render();
  }

  void initWinListener() {
    if (wapi != null)
      wapi.win.onActiveStateChange.listen((state) {
        if (state && stream_changed_ids.isNotEmpty) debounceInRangeGet(null);
      });
  }

  List<cl_form.GridColumn> prepareColumns(List<dynamic> columns) {
    final h = <cl_form.GridColumn>[];
    if (mode == MODE_LIST) {
      m_check = new cl_form.Check('bool')
        ..setValue(true)
        ..setChecked(false)
        ..addAction(checkAll);
      h.add(new cl_form.GridColumn($BaseConsts.check)
        ..title = m_check
        ..width = '1%');
    }
    columns.forEach((hrow) {
      final gc = (hrow is Map) ? mapToGridColumn(hrow) : hrow;
      if (gc.filter != null) initColumnFilter(gc);
      h.add(gc);
    });
    return h;
  }

  void initGrid() {
    if (order == null) {
      final ord = initOrder();
      if (ord != null && ord.length == 2)
        order = new cl_form.GridOrder(ord[0], ord[1]);
    }
    setGrid(new GridList(
        headers: prepareColumns(initHeader()),
        customRow: initRow,
        customRowAfter: customRowAfter,
        initOrder: order,
        hookOrder: (_) {
          order = gridList.grid.order;
          getData();
          return true;
        }));
  }

  void setGrid(GridList grid) {
    gridList?.gridCont?.remove();
    gridList = grid;
    layout.contMiddle.addRow(grid.gridCont..auto = true);
    gridList.gridCont.initLayout();
  }

  void initColumnFilter(cl_form.GridColumn column) {
    void _validateEnter(e) {
      if (cl_util.KeyValidator.isKeyEnter(e)) filterGet(e);
    }

    if (column.filter is List) {
      column.filter.forEach((el_inner) {
        form.add(el_inner);
        el_inner.onValueChanged.listen((_) => filterActive());
        el_inner.addAction(_validateEnter, $BaseConsts.keyup);
      });
    } else {
      form.add(column.filter);
      column.filter.onValueChanged.listen((_) => filterActive());
      column.filter.addAction(_validateEnter, $BaseConsts.keyup);
    }
  }

  void filterActive() {
    menu..setState($BaseConsts.filter, true)..setState($BaseConsts.clear, true);
  }

  cl_form.GridColumn mapToGridColumn(Map hrow) {
    final gc = new cl_form.GridColumn(hrow['key']);
    if (hrow.containsKey('title')) gc.title = hrow['title'];
    if (hrow.containsKey('sortable')) gc.sortable = hrow['sortable'];
    if (hrow.containsKey('width')) gc.width = hrow['width'];
    if (hrow.containsKey('type')) gc.type = hrow['type'];
    if (hrow.containsKey('filter')) gc.filter = hrow['filter'];
    return gc;
  }

  void setActions() {
    if (mode == MODE_LIST) {
      menu.add(new cl_action.Button()
        ..setState(false)
        ..setName($del)
        ..setTitle(intl.Delete())
        ..setIcon(cl.Icon.delete)
        ..addClass('warning')
        ..addAction((e) => delData()));
      if (contr_print != null) {
        final p = new cl_action.ButtonOption()
          ..setName($print)
          ..setDefault(new cl_action.Button()
            ..setTitle(intl.Print())
            ..setIcon(cl.Icon.print)
            ..addAction(printData))
          ..setState(false);
        if (contr_pdf != null)
          p.addSub(new cl_action.Button()
            ..setTitle('PDF')
            ..setIcon(cl.Icon.file_pdf)
            ..addAction(pdfData));
        menu.add(p);
      }
    }
    final filter = new cl_action.ButtonOption()
          ..setName($BaseConsts.filter)
          ..setDefault(new cl_action.Button()
            ..setTitle(intl.Refresh())
            ..setIcon(cl.Icon.filter_list)
            ..addAction(filterGet)),
        clear = new cl_action.Button()
          ..setName($BaseConsts.clear)
          ..setTitle(intl.Clean())
          ..setIcon(cl.Icon.clear)
          ..addAction(filterClear);
    filter.addSub(clear);
    if (useCache) {
      final cache = new cl_action.Button()
        ..setName($BaseConsts.cache)
        ..setTitle(intl.Save())
        ..setIcon(cl.Icon.save)
        ..addAction(saveToCache);
      filter.addSub(cache);
    }
    filter.setState(false);
    menu.add(filter);
  }

  void setHooks() {
    observer
      ..addHook($BaseConsts.get_before, (_) {
        setParamsGet();
        return true;
      })
      ..addHook($BaseConsts.get_after, (_) {
        checkClean();
        setData();
        return true;
      })
      ..addHook($BaseConsts.del_before, (_) {
        setParamsChecked();
        return ask();
      })
      ..addHook($BaseConsts.del_after, (_) {
        checkClean();
        getData();
        return true;
      })
      ..addHook($BaseConsts.print_before, (_) {
        setParamsChecked();
        return true;
      });
  }

  void setPaginator() {
    paginator = new cl_form.Paginator();
    paginator.onValueChanged.listen((_) {
      checkClean();
      getData();
    });
    layout.contBottom.append(paginator);
    layout.contBottom.addClass('ui-menu shadowed');
  }

  List<dynamic> initHeader();

  void registerServerListener(String event, Function f) {
    final subscr = ap.onServerCall.filter(event).listen(f);
    wapi.addCloseHook((_) {
      subscr.cancel();
      return true;
    });
  }

  void debounceInRangeGet(dynamic id) {
    stream_changed_ids.add(id);
    if (!wapi.win.isActive) return;
    debouncer.execute(() {
      if (stream_changed_ids.any(inRange)) getData();
      stream_changed_ids = {};
    });
  }

  void debounceGet(dynamic id) => debouncer.execute(getData);

  bool inRange(dynamic id) {
    final row = gridList.grid.tbody.dom.childNodes.firstWhere(
        (r) => gridList.grid.rowToMap(r)[key] == id,
        orElse: () => null);
    return row != null;
  }

  void onEdit(dynamic id);

  void customRow(TableRowElement row, Map obj) {}

  bool customRowAfter(TableRowElement row, Map obj) => true;

  void filterClear([_]) {
    form.clear();
    menu.setState($BaseConsts.clear, false);
  }

  void filterGet([_]) {
    paginator?.setPage(1);
    getData();
  }

  void saveToCache([_]) {
    final m = form.getValue()..removeWhere((key, value) => value == null);
    ap.storagePut(runtimeType.toString(), m.isEmpty ? null : m);
  }

  void setParamsGet() {
    params = {
      $BaseConsts.order: gridList.grid.order?.toMap(),
      $BaseConsts.paginator: paginator?.getValue(),
      $BaseConsts.filter: form.getValue()
    };
  }

  void setParamsChecked() {
    params = {'ids': chks_set.toList()};
  }

  bool ask([String message]) {
    if (__answer) {
      __answer = false;
      return true;
    }
    final cont = new cl.Container()
      ..append(new ParagraphElement()..text = message ?? intl.Delete_warning())
      ..addClass('center');
    final w = new cl_app.Questioner(ap, cont)
      ..onYes = () {
        __answer = true;
        delData();
        return true;
      }
      ..render();
    w.noDom
      ..addClass('important')
      ..focus();
    return false;
  }

  bool initRow(TableRowElement row, Map obj) {
    customRow(row, obj);
    if (mode == MODE_LIST) initRowCheckAction(row, obj);
    initRowClickAction(row, obj);
    return true;
  }

  void initRowCheckAction(TableRowElement row, Map obj) {
    final chk = new cl_form.Check('bool');
    chk.addAction((e) {
      e.stopPropagation();
      e.preventDefault();
      check(chk, e);
    }, 'click');
    _exp[chk] = obj[key];
    _chk_to_row[chk.hashCode] = row;
    if (_chks_set_tmp.contains(obj[key])) {
      rowCheck(chk);
      chks_set.add(_exp[chk]);
      checkActivation(true);
    }
    chks.add(chk);
    obj['check'] = chk;
  }

  void initRowClickAction(TableRowElement row, Map obj) {
    if (mode == MODE_CHOOSE)
      row.onClick.listen((e) => onClick(row));
    else
      row.onClick.listen((e) => onEdit(obj[key_click ?? key]));
  }

  @Deprecated('User order property instead')
  List<String> initOrder() => [];

  Future actionSend(String type, String controller,
      [cl.CLElement element]) async {
    await ap.loadExecute(element ?? layout.contMiddle, () async {
      if (await observer.execHooksAsync('${type}_before')) {
        _setData(await ap.serverCall(
            controller, params, element ?? layout.contMiddle));
        await observer.execHooksAsync('${type}_after');
      }
    });
  }

  void printer(dynamic contr) {
    if (observer.execHooks($BaseConsts.print_before)) {
      final cont = new cl.Container()
        ..addClass('center')
        ..append(lang_select);
      new cl_app.Confirmer(ap, cont)
        ..title = intl.Language()
        ..icon = cl.Icon.settings
        ..onOk = (() => window.open(
            ap.baseurl +
                contr.reverse([
                  lang_select.getValue(),
                  params['ids'].join(',')
                ]).substring(1),
            ''))
        ..render(width: 200, height: 200);
    }
  }

  void printData([_]) => printer(contr_print);

  void pdfData([_]) => printer(contr_pdf);

  Future<void> getData([cl.CLElement loading]) =>
      actionSend('get', contr_get.reverse([]), loading);

  Future<void> delData([cl.CLElement loading]) =>
      actionSend($del, contr_del.reverse([]), loading);

  void _setData([dynamic data]) {
    data_response = data ?? {$BaseConsts.total: 0, $BaseConsts.result: []};
  }

  void setData() {
    _exp = new Expando();
    paginator?.setTotal(data_response[$BaseConsts.total]);
    final scroll = gridList.grid.scrollTop;
    gridList.grid.empty();
    if (data_response[$BaseConsts.result] != null)
      gridList.grid.renderIt(data_response[$BaseConsts.result]);
    gridList.grid.scrollTop = scroll;
  }

  void checkClean([bool doms = false]) {
    _chks_set_tmp = chks_set;
    if (m_check != null) m_check.setChecked(false);
    if (doms) chks.forEach(rowUncheck);
    chks = {};
    chks_set = {};
    checkActivation(false);
  }

  void onClick(TableRowElement row) {}

  void check(cl_form.Check el, Event e) {
    if (el.getValue())
      rowCheck(el);
    else
      rowUncheck(el);
    if (e is MouseEvent) {
      e.stopPropagation();
      if (e.shiftKey) checkRange(el);
    }
    setChecked();
  }

  void checkRange(cl_form.Check el) {
    var range = false;
    var stop = false;
    chks.forEach((check) {
      if (check == el || check.getValue()) {
        if (!stop) {
          range = true;
          stop = true;
        } else {
          range = false;
        }
      }
      if (range) rowCheck(check);
    });
  }

  void checkAll(Event e) {
    if (m_check.getValue())
      chks.forEach(rowCheck);
    else
      chks.forEach(rowUncheck);
    setChecked();
  }

  void setChecked() {
    chks_set = {};
    chks.forEach((check) {
      if (check.getValue()) chks_set.add(_exp[check]);
    });
    checkActivation(chks_set.isNotEmpty);
  }

  void checkActivation(bool way) {
    menu..setState($del, way)..setState($BaseConsts.print, way);
  }

  void rowCheck(cl_form.Check el) {
    if (el.state) {
      new cl.CLElement(_chk_to_row[el.hashCode]).addClass('selected');
      el.setChecked(true);
    }
  }

  void rowUncheck(cl_form.Check el) {
    if (el.state) {
      new cl.CLElement(_chk_to_row[el.hashCode]).removeClass('selected');
      el.setChecked(false);
    }
  }
}
