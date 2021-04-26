part of forms;

class GridLayout extends GridList<Map> {
  Form formInner = new Form();
  final Form? _form;
  final List<action.Button> _actions = [];

  GridLayout([this._form]) : super() {
    addClass('ui-table-form');

    onReadyChanged.listen(
        (e) => formInner.getNotReady().forEach((el) => el.contrReady.add(el)));
  }

  html.TableRowElement setHeader(List arr) {
    final row = thead.dom.insertRow(-1);
    html.TableCellElement fieldCell;
    arr.forEach((el) {
      fieldCell = cellCreate(row);
      _addEl(el, fieldCell, row);
    });
    return row;
  }

  html.TableRowElement addRow(List arr) {
    //Create row
    final row = tbody.dom.insertRow(-1);
    html.TableCellElement fieldCell;
    arr.forEach((el) {
      fieldCell = cellCreate(row);
      _addEl(el, fieldCell, row);
    });
    return row;
  }

  void _addEl(
      dynamic el, html.TableCellElement fieldCell, html.TableRowElement row) {
    if (el is List) {
      el.forEach((e) => _addEl(e, fieldCell, row));
    } else {
      _register(el);
      if (el is Data && this is GridData)
        el.onValueChanged.listen((e) => rowChanged(row));
      if (el is CLElementBase)
        fieldCell.append(el.dom);
      else if (el is html.Element)
        fieldCell.append(el);
      else if (el is Data)
        return;
      else {
        final t = el?.toString() ?? '';
        fieldCell
          ..setInnerHtml('')
          ..classes.add('text')
          ..title = t
          ..append(new html.SpanElement()..text = t);
      }
    }
  }

  void rowChanged(html.TableRowElement row) {
    if (_form == null) contrValue.add(this);
  }

  void setValue(Map? value) => formInner.setValue(value);

  Map getValue() => formInner.getValue();

  void _register(dynamic el) {
    if (el is gui.LabelField) {
      el.elements.forEach(_register);
    } else if (el is Data) {
      if (_form != null) _form!.add(el);
      formInner.add(el);
    } else if (el is action.Button) {
      _actions.add(el);
    }
  }

  Stream<Data<Map>> get onValueChanged => formInner.onValueChanged;
}
