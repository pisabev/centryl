part of forms;

class GridBase<T> extends DataElement<T, html.TableElement> {
  CLElement<html.TableSectionElement> thead, tbody, tfoot;
  utils.Observer observer = new utils.Observer();

  GridBase() : super() {
    dom = new html.TableElement();
    thead = new CLElement(dom.createTHead())..appendTo(this);
    tbody = new CLElement(dom.createTBody())..appendTo(this);
    tfoot = new CLElement(dom.createTFoot())..appendTo(this);
  }

  html.TableRowElement rowCreate() => tbody.dom.insertRow(-1);

  html.TableCellElement cellCreate(html.TableRowElement row) =>
      row.insertCell(-1);

  html.TableRowElement rowCreateBefore(html.TableRowElement row,
      [html.TableRowElement row_new]) {
    row_new = (row_new != null) ? row_new : new html.TableRowElement();
    tbody.dom.insertBefore(row_new, row.nextElementSibling);
    return row_new;
  }

  void rowRemove(html.TableRowElement row, [bool show = false]) {
    row.remove();
    if (!show && tbody.dom.childNodes.isEmpty) hide();
  }

  void removeChilds() => empty();

  void empty() => tbody.removeChilds();

  void focus() {}

  void blur() {}

  void disable() {}

  void enable() {}
}
