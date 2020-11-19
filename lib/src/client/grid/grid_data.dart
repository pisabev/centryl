part of forms;

class GridData extends GridList<Object> {
  List<html.TableRowElement> insert;
  List<html.TableRowElement> update;
  List<html.TableRowElement> delete;

  bool fullData = false;

  GridData() {
    setClass('ui-table-grid');
    tfoot.hide();
    initSendRows();
    // TODO Fix this - all elements should be passed with isReady/getNotReady
    onReadyChanged
        .listen((e) => getNotReady().forEach((el) => el.contrReady.add(el)));
  }

  void setCellValue(html.TableRowElement row, String key, dynamic value) {
    final m = getRowMap(row);
    if (m[key] is RowDataCell)
      m[key].setValue(value);
    else {
      if (m[key] == value) return;
      m[key] = value;
      rowChanged(row);
    }
  }

  void initSendRows() {
    insert = [];
    update = [];
    delete = [];
  }

  void setValue(Object value) {
    empty();
    if (value is List && value.isNotEmpty) {
      show();
      renderIt(value);
      contrValue.add(this);
    } else {
      hide();
    }
  }

  Object getValue() {
    if (fullData) return getValueAll();
    final m = {};
    if (insert.isNotEmpty) {
      m['insert'] = [];
      insert.forEach((row) => m['insert'].add(rowToMap(row)));
    }
    if (update.isNotEmpty) {
      m['update'] = [];
      update.forEach((row) => m['update'].add(rowToMap(row)));
    }
    if (delete.isNotEmpty) {
      m['delete'] = [];
      delete.forEach((row) => m['delete'].add(rowToMap(row)));
    }
    return m;
  }

  List<Data> getNotReady() {
    final a = <Data>[];
    tbody.dom.childNodes.forEach((row) => getRowMap(row).forEach((k, dc) {
          if (dc is RowDataCell) {
            if (dc.object is Data && !dc.object.isReady()) a.add(dc.object);
            if (dc.object is List)
              a.addAll(dc.object
                  .where((o) => o is Data && !o.isReady())
                  .toList()
                  .cast<Data>());
          }
        }));
    return a;
  }

  bool isReady() =>
      !(_required && tbody.dom.childNodes.isEmpty) &&
      _valid &&
      getNotReady().isEmpty;

  List<html.TableRowElement> rowsAdd(List<Map> rows) {
    final resRows = <html.TableRowElement>[];
    rows.forEach((obj) {
      final row = rowCreate(obj);
      insert.add(row);
      tbody.dom.append(row);
      resRows.add(row);
    });
    show();
    observer.execHooks(GridList.hook_render);
    if (super.num) rowNumRerender();
    contrValue.add(this);
    return resRows;
  }

  html.TableRowElement rowAdd(Map obj) {
    final row = rowCreate(obj);
    insert.add(row);
    tbody.dom.append(row);
    show();
    observer.execHooks(GridList.hook_render);
    if (super.num) rowNumRerender();
    contrValue.add(this);
    return row;
  }

  html.TableRowElement rowAddBefore(html.TableRowElement r, Map obj) {
    final row = rowCreate(obj);
    insert.add(row);
    rowCreateBefore(r, row);
    show();
    observer.execHooks(GridList.hook_render);
    if (super.num) rowNumRerender();
    contrValue.add(this);
    return row;
  }

  html.TableRowElement rowSetBefore(html.TableRowElement r, Map obj) {
    final row = rowCreate(obj);
    rowCreateBefore(r, row);
    show();
    observer.execHooks(GridList.hook_render);
    if (super.num) rowNumRerender();
    contrValue.add(this);
    return row;
  }

  void rowChanged(html.TableRowElement row) {
    var result = insert.contains(row);
    if (!result) {
      result = update.contains(row);
      if (!result) update.add(row);
    }
    contrValue.add(this);
  }

  void rowRemove(html.TableRowElement row, [bool show = false]) {
    row.remove();
    if (!show && tbody.dom.childNodes.isEmpty) hide();
    final result = insert.remove(row);
    if (!result) {
      update.remove(row);
      delete.add(row);
    }
    contrValue.add(this);
    observer.execHooks(GridList.hook_render);
    if (super.num) rowNumRerender();
  }

  bool checkRowValue(String key, dynamic value) {
    for (var i = 0; i < tbody.dom.childNodes.length; i++) {
      //bug dart2js
      try {
        value = value.toString();
      } catch (e) {}
      if (getRowMap(tbody.dom.childNodes[i])[key].toString() == value)
        return true;
    }
    return false;
  }

  html.TableRowElement findRowByKeyValue(String key, dynamic value) {
    html.TableRowElement row;
    for (var i = 0; i < tbody.dom.childNodes.length; i++) {
      if (rowToMap(tbody.dom.childNodes[i])[key] == value) {
        row = tbody.dom.childNodes[i];
        break;
      }
    }
    return row;
  }

  void rowNumRerender() {
    if (this.num)
      for (var i = 0; i < tbody.dom.childNodes.length; i++)
        setCellValue(tbody.dom.childNodes[i], 'position', i + 1);
  }

  int _rowSwap(int s_rownum, int t_rownum) {
    if (s_rownum == t_rownum) return s_rownum;
    final n = math.max(super._rowSwap(s_rownum, t_rownum), 0);
    for (var i = n; i < tbody.dom.childNodes.length; i++)
      rowChanged(tbody.dom.childNodes[i]);
    return n;
  }

  html.TableRowElement rowCreate([Map obj]) {
    final row = super.rowCreate(obj);
    if (!state) disableRow(row);
    return row;
  }

  void disableRow(html.Node row) {
    getRowMap(row).forEach((k, dc) {
      if (dc is RowDataCell) {
        if (dc is RowEditCell)
          dc.disable();
        else if (dc.object is Data || dc.object is action.Button)
          dc.object.disable();
        else if (dc.object is List)
          dc.object.forEach((o) {
            if (o is Data || o is action.Button) o.disable();
          });
      }
    });
  }

  void enableRow(html.Node row) {
    getRowMap(row).forEach((k, dc) {
      if (dc is RowDataCell) {
        if (dc is RowEditCell)
          dc.enable();
        else if (dc.object is Data || dc.object is action.Button)
          dc.object.enable();
        else if (dc.object is List)
          dc.object.forEach((o) {
            if (o is Data || o is action.Button) o.enable();
          });
      }
    });
  }

  void disable() => tbody.dom.childNodes.forEach(disableRow);

  void enable() => tbody.dom.childNodes.forEach(enableRow);

  void rowRemoveAll([bool show = false]) {
    final toDelete = <html.TableRowElement>[];
    tbody.dom.childNodes.forEach(toDelete.add);
    toDelete.forEach((row) => rowRemove(row, show));
  }

  void empty() {
    super.empty();
    initSendRows();
  }
}
