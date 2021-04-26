part of forms;

class CheckList extends DataElement<List, html.DivElement> with DataLoader {
  List<Check> list = [];
  int cols = 3;

  CheckList() : super() {
    dom = new html.DivElement();
    initDataLoader(this);
    _onLoadEndInner.listen((_) {
      final v = getValue();
      renderList(data ?? []);
      if (v != null) _showSelected();
      loadEnd();
    });
  }

  void cleanOptions() {
    removeChilds();
    list = [];
  }

  void renderList(List l) {
    cleanOptions();
    if (l is List) {
      final table = new html.TableElement();
      late html.TableRowElement row;
      var i = 0;
      l.forEach((v) {
        if (i % cols == 0) row = table.addRow();
        final cell = row.addCell();
        final chk_box = new Check('bool')
          ..setName(v['k'])
          ..setLabel(v['v'])
          ..onValueChanged.listen((chk) {
            final c = list.where((c) => c.getValue());
            super.setValue(c.map((el) => el.getName()).toList());
          });
        list.add(chk_box);
        cell.append(chk_box.dom);
        i++;
      });
      append(table);
    }
  }

  void _showSelected() {
    list.forEach((el) => el.setValue(false));
    final value = getValue();
    if (value != null) {
      value.forEach((v) {
        final el = list.firstWhereOrNull((el) => el.getName() == v);
        if (el != null) el.setValue(true);
      });
    }
  }

  void setValue(dynamic value) {
    super.setValue(value);
    if (list.isEmpty && execute is Function) {
      if (!isLoading) load();
      return;
    }
    if (list.isNotEmpty) _showSelected();
  }

  void focus() {}

  void blur() {}

  void disable() {}

  void enable() {}
}
