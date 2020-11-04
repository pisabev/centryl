part of forms;

class GridFormNode extends CLElementBase {
  GridForm parent;
  gui.FormElement form;

  GridFormNode(this.parent);

  void createDom() {
    form = new gui.FormElement();
    dom = form.dom;
    if (parent.drag) _setDraggable(this);
  }

  void _setDraggable(GridFormNode node) {
    node.dom.draggable = true;
    node
      ..addAction((e) {
        e.stopPropagation();
        e.dataTransfer.setData('text', parent.getRowIndex(node).toString());
        e.dataTransfer.effectAllowed = 'move';
      }, 'dragstart')
      ..addAction((e) => node.addClass('ui-drag-over'), 'dragenter')
      ..addAction((e) => node.removeClass('ui-drag-over'), 'dragleave')
      ..addAction((e) {
        e.preventDefault();
        e.stopPropagation();
        e.dataTransfer.dropEffect = 'move';
      }, 'dragover')
      ..addAction((e) {
        parent._rowSwap(int.parse(e.dataTransfer.getData('text')),
            parent.getRowIndex(node));
        e.preventDefault();
        e.stopPropagation();
      }, 'drop');
  }

  void disable() => form.disable();

  void enable() => form.enable();
}

class GridForm extends DataElement<Object, html.DivElement> {
  List<GridFormNode> nodes = [];

  List<GridFormNode> insert;
  List<GridFormNode> update;
  List<GridFormNode> delete;

  static const String hook_row = 'hook_row';
  utils.Observer observer = new utils.Observer();
  final Expando<GridFormNode> _exp = new Expando();
  bool num = false, drag = false;
  bool fullData = false;

  GridForm() {
    dom = new html.DivElement();
    addClass('ui-form-list');
    initSendRows();
    // TODO Fix this - all elements should be passed with isReady/getNotReady
    onReadyChanged
        .listen((e) => getNotReady().forEach((el) => el.contrReady.add(el)));
  }

  void initSendRows() {
    insert = [];
    update = [];
    delete = [];
  }

  void addHookRow(void Function(GridFormNode, Map) func) =>
      observer.addHook(hook_row, (arr) {
        func(arr[0], arr[1]);
        return true;
      });

  void setValue(Object value) {
    empty();
    if (value is List && value.isNotEmpty) {
      value.forEach((r) {
        final node = new GridFormNode(this)..createDom();
        nodes.add(node);
        observer.execHooks(hook_row, [node, r]);
        node.form.onValueChanged.listen((e) {
          if (!update.contains(node)) update.add(node);
          contrValue.add(this);
        });
        _exp[node.dom] = node;
        append(node);
      });
      contrValue.add(this);
      show();
    } else {
      hide();
    }
  }

  bool get isEmpty => nodes.isEmpty;

  List<Map> getValueAll() => nodes.map((row) => row.form.getValue()).toList();

  Object getValue() {
    if (fullData) return getValueAll();
    final m = {};
    if (insert.isNotEmpty) {
      m['insert'] = [];
      insert.forEach((row) => m['insert'].add(row.form.getValue()));
    }
    if (update.isNotEmpty) {
      m['update'] = [];
      update.forEach((row) => m['update'].add(row.form.getValue()));
    }
    if (delete.isNotEmpty) {
      m['delete'] = [];
      delete.forEach((row) => m['delete'].add(row.form.getValue()));
    }
    return m;
  }

  List<Data> getNotReady() {
    final a = <Data>[];
    nodes.forEach((row) {
      a.addAll(row.form.formInner.getNotReady());
    });
    return a;
  }

  bool isReady() =>
      !(_required && nodes.isEmpty) && _valid && getNotReady().isEmpty;

  GridFormNode addValue(Map obj) {
    final node = new GridFormNode(this)..createDom();
    nodes.add(node);
    observer.execHooks(hook_row, [node, obj]);
    node.form.onValueChanged.listen((e) {
      contrValue.add(this);
    });
    _exp[node.dom] = node;
    append(node);
    insert.add(node);
    if (num) rowNumRerender();
    contrValue.add(this);
    return node;
  }

  void nodeRemove(GridFormNode node) {
    node.remove();
    if (insert.contains(node))
      insert.remove(node);
    else {
      if (update.contains(node)) update.remove(node);
      delete.add(node);
    }
    nodes.remove(node);
    if (num) rowNumRerender();
    contrValue.add(this);
  }

  void rowNumRerender() {
    if (drag) {
      for (var i = 0; i < dom.children.length; i++)
        _exp[dom.children[i]]
            .form
            .formInner
            .getElement('position')
            .setValue(i + 1);
    }
  }

  int getRowIndex(GridFormNode node) {
    var ind = 0;
    for (var i = 0; i < nodes.length; i++) {
      if (nodes[i] == node) {
        ind = i;
        break;
      }
    }
    return ind;
  }

  void _rowSwap(int s_rownum, int t_rownum) {
    html.TableRowElement _numRow(n) => dom.children[n];
    if (s_rownum == t_rownum) return;
    if (s_rownum > t_rownum)
      dom.insertBefore(_numRow(s_rownum), _numRow(t_rownum));
    else
      dom.insertBefore(_numRow(s_rownum), _numRow(t_rownum).nextElementSibling);
    rowNumRerender();
  }

  void disable() => nodes.forEach((n) => n.disable());

  void enable() => nodes.forEach((n) => n.enable());

  void empty() {
    removeChilds();
    nodes = [];
    initSendRows();
  }
}
