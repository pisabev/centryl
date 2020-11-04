part of forms;

class RowFormDataCell<T> extends RowDataCell<T> {
  RowFormDataCell(GridColumn column, html.TableRowElement row,
      html.TableCellElement cell, dynamic object)
      : super(column, row, cell, object);

  void render() => _render(object, cell);

  void _render(object, html.TableCellElement cell) {
    if (object is Data && column.grid is GridData) {
      if (column.send)
        object.onValueChanged.listen((e) => column.grid.rowChanged(row));
    }
    if (object is CLElementBase)
      cell.append(object.dom);
    else if (object is html.Element)
      cell.append(object);
    else if (object is Data)
      return;
    else {
      final t = object?.toString() ?? '';
      cell
        ..innerHtml = ''
        ..className = 'text'
        ..title = t
        ..append(new html.SpanElement()..text = t);
    }
  }

  dynamic _getValue(object) {
    if (object is Data)
      return object.getValue();
    else if (object is List)
      return object.whereType<Data>().map(_getValue).toList();
    else
      return object;
  }

  dynamic getValue() => _getValue(object);

  void setValue(dynamic value) {
    if (object is Data) {
      (object as Data).setValue(value);
    } else
      super.setValue(value);
  }
}
