part of calendar;

class MonthContainer {
  CLElement dom;
  late CLElement dragCont;

  EventCalendar calendar;

  late List<MonthCell> cells;
  late List<MonthRow> rows;

  MonthCell? startCell, endCell;

  MonthContainer(this.dom, this.calendar) {
    dragCont = new CLElement(new html.DivElement())..setClass('drag-grid');
  }

  void setDragable(MonthRow row) {
    new utils.Drag(row)
      ..start(onDrag)
      ..on(onDrag)
      ..end(release);
  }

  MonthCell? getCellByEvent(html.MouseEvent e) =>
      cells.firstWhereOrNull((cell) => cell
          .getRectangle()
          .containsPoint(new math.Point(e.client.x, e.client.y)));

  void onDrag(html.MouseEvent e) {
    final cell = getCellByEvent(e);
    if (cell == null) return;
    if (calendar.filters.isNotEmpty &&
        !rows.any((d) => d.fCol.inRange(cell.date, cell.date))) return;
    startCell ??= cell;
    endCell = cell;
    dragCont
      ..removeChilds()
      ..appendTo(dom);
    highLight(startCell!, endCell!, dragCont);
  }

  void onDragEvent(html.MouseEvent e, Event drag) {
    final cell = getCellByEvent(e);
    if (cell == null) return;
    final offset_date = utils.Calendar.UTCAdd(
        cell.date,
        new Duration(
            hours: utils.Calendar.UTCDifference(drag.end, drag.start).inHours));
    var cell2 =
        cells.firstWhereOrNull((mc) => mc.date.compareTo(offset_date) == 0);
    if (!drag.isAllDayEvent()) cell2 = cell;
    cell2 ??= cells.last;
    if (calendar.filters.isNotEmpty &&
        !rows.any((d) => d.fCol.inRange(cell.date, cell2!.date))) return;
    startCell = cell;
    endCell = cell2;
    dragCont
      ..removeChilds()
      ..appendTo(dom);
    highLight(startCell!, endCell!, dragCont);
  }

  Future onDropEvent(html.MouseEvent e, Event drag) async {
    if (startCell == null) return;
    final new_start = drag.start
        .add(startCell!.date.difference(EventCalendar.normDate(drag.start)));
    final new_end = new_start.add(drag.end.difference(drag.start));
    drag
      ..start = new_start
      ..end = new_end;

    if (drag.changed()) await calendar.persistEvent(drag);

    dragCont.remove();
    rows.forEach((row) {
      row
        ..setEvents(calendar.events)
        ..render();
    });
    calendar.changed();
    startCell = null;
    endCell = null;
  }

  void highLight(MonthCell start, MonthCell end, CLElement container) {
    final m = {};
    cells.forEach((cell) {
      if (utils.Calendar.dateBetween(cell.date, start.date, end.date)) {
        final rect = cell.getMutableRectangle();
        if (m[rect.top] == null) m[rect.top] = [];
        m[rect.top].add(rect);
      }
    });
    final top = calendar.body.getRectangle();
    m.forEach((k, v) {
      final rect = v.first;
      new CLElement(new html.DivElement())
        ..setStyle({
          'width': '${v.last.left - rect.left + rect.width + 1}px',
          'height': '${rect.height}px',
          'top': '${rect.top + html.document.body!.scrollTop - top.top}px',
          'left': '${rect.left + html.document.body!.scrollLeft - top.left}px'
        })
        ..appendTo(container);
    });
  }

  void release(html.MouseEvent e) {
    if (startCell == null || endCell == null) return;
    calendar.createEvent(utils.Calendar.min(startCell!.date, endCell!.date),
        utils.Calendar.max(startCell!.date, endCell!.date), true);
    dragCont.remove();
    rows.forEach((row) {
      row
        ..setEvents(calendar.events)
        ..render();
    });
    calendar.changed();
    startCell = null;
    endCell = null;
  }
}
