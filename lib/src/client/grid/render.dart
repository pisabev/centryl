part of forms;

class RenderBuffered extends RenderBase {
  List<html.TableRowElement> rows;

  int visibleSet = 50;
  int offset = 20;
  int _currentSet = -1;

  CLElement _fixBefore;
  CLElement _fixAfter;

  RenderBuffered();

  void setGrid(GridBase grid) {
    super.setGrid(grid);
    _fixBefore = new CLElement(grid.dom.createTBody())..addClass('tbody-fix');
    _fixAfter = new CLElement(grid.dom.createTBody())..addClass('tbody-fix');
    grid
      ..insertBefore(grid.tbody, _fixBefore)
      ..insertBefore(grid.tbody, _fixAfter);
    _fixBefore.append(new html.TableRowElement());
    _fixAfter.append(new html.TableRowElement());
  }

  void renderIt(List data) {
    rows = [];
    _currentSet = -1;
    grid.map.forEach((k, gc) => gc.resetAggregator());
    for (var i = 0; i < data.length; i++) grid.rowCreate(data[i]);
    if (grid.num) grid.rowNumRerender();
    grid.map.forEach((k, gc) => gc.renderAggregator(rows));
    if (rows.isNotEmpty) onScroll();
  }

  void setTbodyWidths([bool auto = false]) {
    if (auto == true) return;
    if (tbodyWidths != null &&
        tbodyWidths.isNotEmpty &&
        grid.tbody.dom.childNodes.isNotEmpty) {
      if (_fixBefore.dom.firstChild.childNodes.isEmpty) {
        for (var i = 0; i < tbodyWidths.length; i++) {
          final c = new html.TableCellElement()
            ..style.height = '0'
            ..style.padding = '0'
            ..style.margin = '0'
            ..style.width = '${tbodyWidths[i]}px';
          _fixBefore.dom.firstChild.append(c);
        }
      } else {
        final firstRow = _fixBefore.dom.children.first;
        for (var i = 0; i < firstRow.children.length; i++)
          firstRow.children[i].style.width = '${tbodyWidths[i]}px';
      }
    }
  }

  void _renderSubList(int listStart, int listEnd) {
    final sublist = rows.sublist(listStart, listEnd);
    final frg = html.document.createDocumentFragment();
    for (var i = 0; i < sublist.length; i++) frg.append(sublist[i]);
    grid.tbody.removeChilds();
    grid.tbody.dom.append(frg);
    grid.map.forEach((k, gc) {
      if (gc.aggregator != null && gc.aggregator.selector != null)
        gc.aggregator.selector.section.offset = listStart;
    });
  }

  void onScroll([int scrollTop = 0, bool render = true]) {
    final rowHeight = this.rowHeight;
    final visibleSetHeight = rowHeight * visibleSet;
    if (visibleSetHeight == 0) return;
    final set = (scrollTop / visibleSetHeight).floor();
    if (set == _currentSet) return;
    _currentSet = set;
    final r = set * visibleSet;
    final listStart = math.max(math.min(r, rows.length), 0);
    final listEnd = math.min(r + visibleSet + offset, rows.length);
    final totalHeight = rows.length * rowHeight;
    final topHeight = r * rowHeight;
    final subListHeight = (listEnd - listStart) * rowHeight;
    final bottomHeight = totalHeight - topHeight - subListHeight;
    _fixBefore.dom.children.first.style.height = '${topHeight}px';
    _fixAfter.dom.children.first.style.height = '${bottomHeight}px';
    if (render) _renderSubList(listStart, listEnd);
  }
}

class Render extends RenderBase {
  Render() : super();

  void renderIt(List data) {
    rows = [];
    final frg = html.document.createDocumentFragment();
    grid.map.forEach((k, gc) => gc.resetAggregator());
    for (var i = 0; i < data.length; i++)
      frg.append(grid.rowCreate(data[i]));
    grid.tbody.dom.append(frg);
    if (grid.num) grid.rowNumRerender();
    grid.map.forEach((k, gc) => gc.renderAggregator(gc.grid.tbody.dom.rows));
  }

  void onScroll([int scrollTop, bool render]) {}
}
