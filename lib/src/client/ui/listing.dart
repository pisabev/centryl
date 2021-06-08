part of ui;

class ListingContainerBase extends cl.Container {
  late cl.Container contMenu, contMiddle, contBottom;
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
  late cl_form.GridListContainer gridCont;
  late cl_form.GridList grid;

  GridList(
      {required List<cl_form.GridColumn> headers,
      required bool Function(TableRowElement row, Map data) customRow,
      cl_form.GridOrder? initOrder,
      bool Function(TableRowElement row, Map data)? customRowAfter,
      FutureOr<bool> Function(dynamic)? hookOrder}) {
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

  UrlPattern? contr_get, contr_del, contr_pdf;

  cl_app.Application<C> ap;
  late cl_app.WinMeta meta;
  cl_app.WinApp<C>? wapi;
  late ListingContainer layout;
  Expando? _exp;

  late cl_form.Form form;
  late cl_action.Menu menu;
  GridList? gridList;
  late cl_util.Observer observer;
  Map? params;
  dynamic data_response;
  cl_form.Check? m_check;
  cl_form.GridOrder? order;
  Set<cl_form.Check> chks = {};
  Set<Object> chks_set = {};
  Set<Object> _chks_set_tmp = {};
  cl_form.Paginator? paginator;

  bool fixedFooter = false;
  bool __answer = false;
  bool useCache;
  final Map<int, TableRowElement> _chk_to_row = {};

  Debouncer debouncer = new Debouncer(const Duration(milliseconds: 200));
  Set<Object> stream_changed_ids = {};

  late String key;
  String? mode;
  String? key_click;

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
    wapi!.win.getContent().append(layout, scrollable: true);
    wapi!.render();
  }

  void initWinListener() {
    wapi?.win.onActiveStateChange.listen((state) {
      if (state && stream_changed_ids.isNotEmpty) debounceInRangeGet(null);
    });
  }

  List<cl_form.GridColumn> prepareColumns(List<dynamic> columns) {
    final h = <cl_form.GridColumn>[];
    if (mode != null && mode == MODE_LIST) {
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
      if (ord.length == 2) order = new cl_form.GridOrder(ord[0], ord[1]);
    }
    setGrid(new GridList(
        headers: prepareColumns(initHeader()),
        customRow: initRow,
        customRowAfter: customRowAfter,
        initOrder: order,
        hookOrder: (_) {
          order = gridList?.grid.order;
          getData();
          return true;
        }));
  }

  void setGrid(GridList grid) {
    gridList?.gridCont.remove();
    gridList = grid;
    layout.contMiddle.addRow(grid.gridCont..auto = true);
    gridList?.gridCont.initLayout();
  }

  void initColumnFilter(cl_form.GridColumn column) {
    void _validateEnter(e) {
      if (cl_util.KeyValidator.isKeyEnter(e)) filterGet(e);
    }

    if (column.filter is List) {
      column.filter.forEach((el_inner) {
        form.add(el_inner);
        el_inner.addAction(_validateEnter, $BaseConsts.keyup);
      });
    } else {
      form.add(column.filter);
      column.filter.addAction(_validateEnter, $BaseConsts.keyup);
    }
    form.onValueChanged.listen((_) => filterActive());
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
    }
    final filter = new cl_action.ButtonOption()
          ..setName($BaseConsts.filter)
          ..setDefault(new cl_action.Button()
            ..setTitle(intl.Refresh())
            ..setIcon(cl.Icon.sync)
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
    paginator!.onValueChanged.listen((_) {
      checkClean();
      getData();
    });
    layout.contBottom.append(paginator);
    layout.contBottom.addClass('ui-menu shadowed');
  }

  List<dynamic> initHeader();

  void registerServerListener(String event, void Function(dynamic) f) {
    final subscr = ap.onServerCall.filter(event).listen(f);
    wapi?.addCloseHook((_) {
      subscr.cancel();
      return true;
    });
  }

  void debounceInRangeGet(dynamic id) {
    stream_changed_ids.add(id);
    if (wapi != null && !wapi!.win.isActive) return;
    debouncer.execute(() {
      if (stream_changed_ids.any(inRange)) getData();
      stream_changed_ids = {};
    });
  }

  void debounceGet(dynamic id) => debouncer.execute(getData);

  bool inRange(dynamic id) {
    final row = gridList?.grid.tbody.dom.childNodes.firstWhereOrNull((r) =>
        gridList?.grid.getRowMapSerialized(r as TableRowElement)[key] == id);
    return row != null;
  }

  void onEdit(dynamic id);

  void customRow(TableRowElement row, Map obj) {}

  bool customRowAfter(TableRowElement row, Map obj) => true;

  void filterClear([_]) {
    form.clear();
  }

  void filterActive() {
    final values = form.getValue();
    bool way = false;
    values.forEach((k, v) {
      if (way == true) return;
      if (v is List)
        way = v.any((e) => e != null);
      else
        way = v != null;
    });
    (menu[$BaseConsts.filter] as cl_action.ButtonOption)
        .buttonDefault
        ?.setIcon(way ? cl.Icon.filter_list : cl.Icon.sync);
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
      $BaseConsts.order: gridList?.grid.order?.toMap(),
      $BaseConsts.paginator: paginator?.getValue(),
      $BaseConsts.filter: form.getValue()
    };
  }

  void setParamsChecked() {
    params = {'ids': chks_set.toList()};
  }

  bool ask([String? message]) {
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
    chk.addAction<Event>((e) {
      e
        ..stopPropagation()
        ..preventDefault();
      check(chk, e);
    }, 'click');
    _exp![chk] = obj[key];
    _chk_to_row[chk.hashCode] = row;
    if (_chks_set_tmp.contains(obj[key])) {
      rowCheck(chk);
      chks_set.add(_exp![chk]!);
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
      [cl.CLElement? element]) async {
    await ap.loadExecute(element ?? layout.contMiddle, () async {
      if (await observer.execHooksAsync('${type}_before')) {
        _setData(await ap.serverCall(
            controller, params, element ?? layout.contMiddle));
        await observer.execHooksAsync('${type}_after');
      }
    });
  }

  Future<void>? getData([cl.CLElement? loading]) => contr_get != null
      ? actionSend('get', contr_get!.reverse([]), loading)
      : null;

  Future<void>? delData([cl.CLElement? loading]) => contr_del != null
      ? actionSend($del, contr_del!.reverse([]), loading)
      : null;

  void _setData([dynamic data]) {
    data_response = data ?? {$BaseConsts.total: 0, $BaseConsts.result: []};
  }

  void setData() {
    _exp = new Expando();
    paginator?.setTotal(data_response[$BaseConsts.total]);
    final scroll = gridList?.grid.scrollTop;
    gridList?.grid.empty();
    if (data_response[$BaseConsts.result] != null)
      gridList?.grid.renderIt(data_response[$BaseConsts.result]);
    if (scroll != null) gridList?.grid.scrollTop = scroll;
  }

  void checkClean([bool doms = false]) {
    _chks_set_tmp = chks_set;
    if (m_check != null) m_check!.setChecked(false);
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
    if (m_check?.getValue())
      chks.forEach(rowCheck);
    else
      chks.forEach(rowUncheck);
    setChecked();
  }

  void setChecked() {
    chks_set = {};
    chks.forEach((check) {
      if (check.getValue()) chks_set.add(_exp![check]!);
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
