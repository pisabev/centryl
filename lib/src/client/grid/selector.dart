part of forms;

class _GridPos {
  int col;
  int row;
}

class _Section {
  _GridPos topLeft;
  _GridPos bottomRight;
  final List<html.TableRowElement> rows;
  List<html.TableCellElement> selected = [];
  int offset;
  static const String clas = 'highlighted';

  _Section(this.rows, [this.offset = 0]) {
    topLeft = bottomRight = new _GridPos()
      ..col = 0
      ..row = 0;
  }

  math.Rectangle _getSelectionRect() => new math.Rectangle(
      math.min(topLeft.col, bottomRight.col),
      math.min(topLeft.row, bottomRight.row),
      math.max(topLeft.col, bottomRight.col),
      math.max(topLeft.row, bottomRight.row));

  void setTopLeft(html.TableCellElement element) {
    topLeft = _getCellPos(element);
    selected.forEach((c) => c.classes.remove(clas));
    selected = _getSelectedCells(_getSelectionRect())
      ..forEach((c) => c.classes.add(clas));
  }

  void setBottomRight(html.TableCellElement element) {
    bottomRight = _getCellPos(element);
    selected.forEach((c) => c.classes.remove(clas));
    selected = _getSelectedCells(_getSelectionRect())
      ..forEach((c) => c.classes.add(clas));
  }

  void addRemoveElement(html.TableCellElement element) {
    if (selected.contains(element))
      selected.remove(element..classes.remove(clas));
    else
      selected.add(element..classes.add(clas));
  }

  void clean() {
    selected.forEach((c) => c.classes.remove(clas));
    selected = [];
  }

  _GridPos _getCellPos(html.TableCellElement element) {
    final parent = element.parent as html.TableRowElement;
    return new _GridPos()
      ..col = element.cellIndex
      ..row = offset + parent.rowIndex;
  }

  List<html.TableCellElement> _getSelectedCells(math.Rectangle rect) {
    final List<html.TableCellElement> l = [];
    for (var i = 0; i < rows.length; i++) {
      final tr = rows[i];
      final rowIndex = i + 1;
      if (rowIndex >= rect.top && rowIndex <= rect.height) {
        for (var j = 0; j < tr.childNodes.length; j++) {
          final td = tr.cells[j];
          if (td.cellIndex >= rect.left && td.cellIndex <= rect.width)
            l.add(td);
        }
      }
    }
    return l;
  }
}

class Selector {
  _Section section;
  GridColumn gc;
  CLElement label;
  Sumator sum;
  List<html.TableRowElement> rows;
  List<html.TableCellElement> cells;
  bool text;

  Selector(this.sum, {this.text = true});

  void startSelection(CLElement<html.TableCellElement> el, html.MouseEvent e) {
    e
      ..stopPropagation()
      ..preventDefault();
    label?.hide();
    if (e.ctrlKey) {
      section.addRemoveElement(el.dom);
    } else if (e.shiftKey) {
      section.setBottomRight(el.dom);
    } else {
      section
        ..setTopLeft(el.dom)
        ..setBottomRight(el.dom);
      cells.forEach((td) {
        final elem = new CLElement(td);
        elem.addAction((e) => section.setBottomRight(elem.dom),
            'mouseover.selector${section.hashCode}');
      });
    }
  }

  void stopSelection() {
    cells.forEach((td) => new CLElement(td)
        .removeAction('mouseover.selector${section.hashCode}'));
  }

  void clearAll() {
    section.clean();
    label?.hide();
    stopSelection();
  }

  List<html.TableCellElement> getCells() {
    final arr = <html.TableCellElement>[];
    for (var i = 0; i < rows.length; i++) {
      final tr = rows[i];
      for (var j = 0; j < tr.childNodes.length; j++) {
        final td = tr.cells[j];
        if (td.cellIndex == gc.cell_index) {
          arr.add(td);
        }
      }
    }
    return arr;
  }

  void getLabel() {
    sum.nullify();
    if (section.selected.isEmpty) return;
    section.selected.forEach((sel) {
      final obj = gc.grid.getRowMap(sel.parent);
      sum.add(obj[gc.key].object);
    });
    final last = section.selected.last;
    label ??= new CLElement(new html.SpanElement())..addClass('sum-label');
    label.appendTo(gc.grid);
    final el = new CLElement(last),
        offset = el.getHeight(),
        pos_tbody = gc.grid.getRectangle(),
        pos_cell = el.getRectangle(),
        pos = {
          'top': pos_cell.top - pos_tbody.top,
          'left': pos_cell.left - pos_tbody.left,
        };
    label.setStyle({
      'display': 'block',
      'top': '${pos['top'] + offset}px',
      'left': '${pos['left']}px',
      'z-index': '1'
    });
    if (text)
      label.dom.text = 'Σ = ${sum.total}';
    else {
      label.dom.innerHtml = '';
      label.dom.append(sum.total);
    }
  }

  void init(GridColumn column, List<html.TableRowElement> gridRows) {
    gc = column;
    rows = gridRows;
    section = new _Section(rows, 1 - gc.grid.thead.dom.children.length);
    cells = getCells()
      ..forEach((td) {
        final el = new CLElement<html.TableCellElement>(td);
        el
          ..addClass('hightlightable')
          ..addAction((e) {
            startSelection(el, e);
            final doc = new CLElement(html.document.body);
            doc.addAction((e) {
              clearAll();
              doc.removeAction('mousedown.selector${section.hashCode}');
            }, 'mousedown.selector${section.hashCode}');
          }, 'mousedown.selector${section.hashCode}')
          ..addAction((e) {
            e.stopPropagation();
            stopSelection();
            getLabel();
          }, 'mouseup.selector${section.hashCode}');
      });
  }
}
