part of forms;

abstract class RenderBase {
  List<html.TableRowElement> rows;
  GridList grid;

  List<num> tbodyWidths;
  List<num> theadWidths;
  List<num> tfootWidths;
  num rowHeight = 30;

  RenderBase();

  void setGrid(GridList grid) => this.grid = grid;

  void renderIt(List data);

  void onScroll([int scrollTop, bool render]);

  void setRowHeight() {
    int total = 0;
    grid.tbody.dom.rows.forEach((r) => total += r.offsetHeight);
    rowHeight = total ~/ grid.tbody.dom.rows.length;
    if (rowHeight == 0) rowHeight = 30;
  }

  void calcTbodyWidths() {
    tbodyWidths = [];
    final firstRow = grid.tbody.dom.rows[0];
    for (var i = 0; i < firstRow.childNodes.length; i++)
      tbodyWidths.add(new CLElement(firstRow.cells[i]).getWidthComputed());
  }

  void calcTheadWidths() {
    theadWidths = [];
    final firstRow = grid.thead.dom.rows.last;
    for (var i = 0; i < firstRow.childNodes.length; i++)
      theadWidths.add(new CLElement(firstRow.cells[i]).getWidthComputed());
  }

  void calcTfootWidths() {
    tfootWidths = [];
    if (grid.tfoot.dom.rows.isEmpty) return;
    final firstRow = grid.tfoot.dom.rows[0];
    for (var i = 0; i < firstRow.childNodes.length; i++)
      tfootWidths.add(new CLElement(firstRow.cells[i]).getWidthComputed());
  }

  void setTbodyWidths([bool auto = false]) {
    if (tbodyWidths != null &&
        tbodyWidths.isNotEmpty &&
        grid.tbody.dom.childNodes.isNotEmpty) {
      final firstRow = grid.tbody.dom.childNodes[0];
      for (var i = 0; i < firstRow.childNodes.length; i++) {
        final cl = new CLElement(firstRow.childNodes[i]);
        if (auto)
          cl.setStyle({'width': 'auto'});
        else
          cl.setStyle({'width': '${tbodyWidths[i]}px'});
      }
    }
  }

  void setTheadWidths([bool auto = false]) {
    if (theadWidths != null && theadWidths.isNotEmpty) {
      final firstRow = grid.thead.dom.rows.last;
      for (var i = 0; i < firstRow.childNodes.length; i++) {
        final cl = new CLElement(firstRow.childNodes[i]);
        if (auto)
          cl.setStyle({'width': 'auto'});
        else
          cl.setStyle({'width': '${theadWidths[i]}px'});
      }
    }
  }

  void setTfootWidths([bool auto = false]) {
    if (tfootWidths != null && tfootWidths.isNotEmpty) {
      final firstRow = grid.tfoot.dom.childNodes[0];
      for (var i = 0; i < firstRow.childNodes.length; i++) {
        final cl = new CLElement(firstRow.childNodes[i]);
        if (auto)
          cl.setStyle({'width': 'auto'});
        else
          cl.setStyle({'width': '${tfootWidths[i]}px'});
      }
    }
  }
}
