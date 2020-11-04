part of forms;

class RowDataCell<T> {
  final GridColumn column;

  final html.TableRowElement row;

  final html.TableCellElement cell;

  T object;

  RowDataCell(this.column, this.row, this.cell, this.object);

  void render() {
    final t = object?.toString() ?? '';
    cell
      ..innerHtml = ''
      ..className = 'text'
      ..title = t
      ..append(new html.SpanElement()..text = t);
  }

  void setValue(dynamic value) {
    if (object == value) return;
    object = value;
    render();
    if (column.send) column.grid.rowChanged(row);
  }

  dynamic getValue() => object;
}
