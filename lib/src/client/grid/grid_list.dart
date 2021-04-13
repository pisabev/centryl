part of forms;

typedef _HookRowFunction = void Function(html.TableRowElement, Map);

class GridOrder {
  final String field;
  final String way;

  GridOrder(this.field, this.way);

  Map<String, String> toMap() => {'field': field, 'way': way};
}

class GridList<T> extends GridBase<T> {
  static const String hook_order = 'hook_order';
  static const String hook_row = 'hook_row';
  static const String hook_row_after = 'hook_row_after';
  static const String hook_render = 'hook_render';
  static const String hook_layout = 'hook_layout';

  final Expando _exp = new Expando();

  html.TableRowElement _rowTemplate;

  bool num = false, _drag = false;

  List tbodyWidths;
  List theadWidths;

  Map<String, GridColumn> map = {};

  GridOrder order;

  RenderBase renderer;

  GridList([RenderBase renderer]) : super() {
    this.renderer = (renderer == null) ? new Render() : renderer;
    this.renderer.setGrid(this);
    setClass('ui-table-list');
  }

  set drag(bool v) {
    _drag = v;
    num = v;
  }

  bool get drag => _drag;

  dynamic getCell(html.TableRowElement row, String key) => getRowMap(row)[key];

  void addHookRow(_HookRowFunction func) => observer.addHook(hook_row, (arr) {
        func(arr[0], arr[1]);
        return true;
      });

  void addHookRowAfter(_HookRowFunction func) =>
      observer.addHook(hook_row_after, (arr) {
        func(arr[0], arr[1]);
        return true;
      });

  void addHookRender(utils.ObserverFunction func) =>
      observer.addHook(hook_render, func);

  void addHookLayout(utils.ObserverFunction func) =>
      observer.addHook(hook_layout, func);

  void addHookOrder(utils.ObserverFunction func) =>
      observer.addHook(hook_order, func);

  void initGridHeader(List<GridColumn> headers) {
    thead.removeChilds();
    tfoot.removeChilds();

    if (num && headers.every((h) => h.key != 'position')) {
      headers.insert(
          0,
          new GridColumn('position')
            ..title = null
            ..send = false);
    }
    final Map<String, List<GridColumn>> groups = {};
    int counter = 0;
    String currentEmpty;
    bool hasGroups = false;
    headers.forEach((g) {
      String gr;
      if (g.group == null) {
        gr = currentEmpty ??= '___${counter++}___';
      } else {
        hasGroups = true;
        currentEmpty = null;
        gr = g.group;
      }

      if (groups[gr] == null) groups[gr] = [];
      groups[gr].add(g);
    });

    html.TableRowElement rowg;

    _rowTemplate = new html.TableRowElement();
    int gridCount = 0;
    html.TableRowElement rowh;
    html.TableRowElement rowf;

    groups.forEach((k, d) {
      if (hasGroups) {
        rowg = rowg ?? thead.dom.insertRow(-1);
        final c = rowg.insertCell(-1)
          ..colSpan = d.where((g) => g.visible).length;
        if (!new RegExp(r'^___\d+___$').hasMatch(k)) {
          c.append(new html.DivElement()
            ..text = k
            ..classes.add('group'));
        }
      }

      rowh = rowh ?? thead.dom.insertRow(-1);
      rowf = rowf ?? tfoot.dom.insertRow(-1);

      d.forEach((h) {
        map[h.key] = h;
        h.grid = this;
        if (h.visible) {
          h
            ..headerCell = rowh.insertCell(-1)
            ..footerCell = rowf.insertCell(-1)
            ..cell_index = gridCount++;
          _rowTemplate.insertCell(-1);
          h.renderTitle();
        }
        h.type = h.type ??
            (column, row, cell, object) =>
                new RowFormDataCell(column, row, cell, object);
      });
    });
  }

  bool get isEmpty => tbody.dom.childNodes.isEmpty;

  @Deprecated('Use initGridHeader instead.')
  void initHeader(List<Map> data) {
    final d = <GridColumn>[];
    data.forEach((hrow) {
      final gc = new GridColumn(hrow['key']);
      if (hrow.containsKey('title')) gc.title = hrow['title'];
      if (hrow.containsKey('visible')) gc.visible = hrow['visible'];
      if (hrow.containsKey('sortable')) gc.sortable = hrow['sortable'];
      if (hrow.containsKey('filter')) gc.filter = hrow['filter'];
      if (hrow.containsKey('type')) gc.type = hrow['type'];
      if (hrow.containsKey('width')) gc.width = hrow['width'];
      if (hrow.containsKey('send')) gc.send = hrow['send'];
      if (hrow.containsKey('aggregator')) gc.aggregator = hrow['aggregator'];
      d.add(gc);
    });
    return initGridHeader(d);
  }

  void setOrder(GridOrder ord) {
    order = ord;
    observer.execHooks(hook_order);
  }

  void renderIt(List data) {
    renderer.renderIt(data);
    observer.execHooks(hook_render);
  }

  html.TableRowElement rowAdd(Map obj) {
    final row = rowCreate(obj);
    tbody.dom.append(row);
    if (num) rowNumRerender();
    map.forEach((k, gc) => gc.renderAggregator(renderer.rows));
    return row;
  }

  void rowNumRerender() {
    if (num) {
      for (var i = 0; i < tbody.dom.childNodes.length; i++)
        tbody.dom.rows[i].cells[0].text = (i + 1).toString();
    }
  }

  void rowSet(html.TableRowElement row, Map obj) {
    _exp[row] = obj;
    obj.forEach((k, v) {
      final gc = map[k];
      if (gc != null) {
        if (gc.visible) {
          final cell = row.cells[gc.cell_index];
          if (gc.title is String) cell.setAttribute('data-title', gc.title);
          final RowDataCell c = obj[k] = gc.type(gc, row, cell, v)..render();
          gc.aggregator?.add(c);
        }
      }
    });
    if (num && !obj.containsKey('position')) {
      final gc = map['position'];
      if (gc.visible)
        obj['position'] =
            gc.type(gc, row, row.cells[gc.cell_index]..className = 'num', 0);
    }
  }

  html.TableRowElement rowCreate([Map obj]) {
    final row = _rowTemplate.clone(true);
    renderer.rows.add(row);
    if (drag) _setDraggable(row);
    observer.execHooks(hook_row, [row, obj]);
    rowSet(row, obj);
    observer.execHooks(hook_row_after, [row, obj]);
    return row;
  }

  void rowRemove(html.TableRowElement row, [bool show = false]) {
    super.rowRemove(row, show);
    renderer.rows.remove(row);
    map.forEach((k, gc) => gc
      ..aggregator?.remove(getCell(row, k))
      ..renderAggregator(renderer.rows));
    if (num) rowNumRerender();
  }

  Map getRowMap(html.TableRowElement row) => _exp[row];

  Map getRowMapSerialized(html.TableRowElement row) {
    final m = {};
    getRowMap(row).forEach((k, dynamic dc) {
      if (dc is RowDataCell) {
        if (map.containsKey(k) && map[k] != null && map[k]!.send)
          m[k] = dc.getValue();
      } else
        m[k] = dc;
    });
    return m;
  }

  List<Map> getValueAll() => tbody.dom.childNodes
      .map<Map>((row) => getRowMapSerialized(row as html.TableRowElement))
      .toList();

  void rowChanged(html.TableRowElement row) {}

  void _setDraggable(row) {
    row.draggable = true;
    final el = new CLElement(row);
    el
      ..addAction((e) {
        e.stopPropagation();
        e.dataTransfer.setData('text', getRowIndex(el.dom).toString());
        e.dataTransfer.effectAllowed = 'move';
      }, 'dragstart')
      ..addAction((e) => el.addClass('ui-drag-over'), 'dragenter')
      ..addAction((e) => el.removeClass('ui-drag-over'), 'dragleave')
      ..addAction((e) {
        e.preventDefault();
        e.stopPropagation();
        e.dataTransfer.dropEffect = 'move';
      }, 'dragover')
      ..addAction((e) {
        _rowSwap(
            int.parse(e.dataTransfer.getData('text')), getRowIndex(el.dom));
        e.preventDefault();
        e.stopPropagation();
      }, 'drop');
  }

  int _rowSwap(int s_rownum, int t_rownum) {
    html.TableRowElement _numRow(n) => tbody.dom.rows[n];
    if (s_rownum == t_rownum) return 0;
    if (s_rownum > t_rownum)
      tbody.dom.insertBefore(_numRow(s_rownum), _numRow(t_rownum));
    else
      tbody.dom.insertBefore(
          _numRow(s_rownum), _numRow(t_rownum).nextElementSibling);
    rowNumRerender();
    return math.min(s_rownum, t_rownum);
  }

  int getRowIndex(html.TableRowElement row) =>
      row.rowIndex - thead.dom.childNodes.length;

  int get scrollTop => tbody.dom.scrollTop;

  set scrollTop(int scroll_top) {
    tbody.dom.scrollTop = scroll_top;
  }

  void empty() {
    super.empty();
    renderer.rows = [];
  }
}
