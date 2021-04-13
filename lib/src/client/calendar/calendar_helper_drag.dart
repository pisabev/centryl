part of calendar;

class CalendarHelperDrag {
  late EventCalendar calendar;

  List<List<CalendarHelperCell>> rows;

  CalendarHelperCell? startCell;

  StreamSubscription? _documentUp;

  Function? _currentSectionView;

  DateTime? _dateStart;
  DateTime? _dateEnd;

  CalendarHelperDrag(this.rows);

  void setDraggable() {
    rows.forEach((row) {
      row.forEach((cell) {
        cell
          ..addAction((e) => startDrag(cell), 'mousedown')
          ..addAction((e) => over(cell), 'mouseover')
          ..addAction((e) => render(), 'mouseup');
      });
    });
    _documentUp ??= html.document.onMouseUp.listen((e) {
      startCell = null;
    });
  }

  void _clear() {
    _dateStart = null;
    _dateEnd = null;
    rows.forEach((row) {
      row.forEach((cell) {
        cell.removeClass('selected');
      });
    });
  }

  void fillRange(CalendarHelperCell start, CalendarHelperCell end,
      [bool full_row = false]) {
    late CalendarHelperCell first, last;
    rows.forEach((row) {
      row.forEach((cell) {
        if (full_row) {
          if (start.date.compareTo(cell.date) == 0) first = row.first;
          if (end.date.compareTo(cell.date) == 0) last = row.last;
        } else {
          if (utils.Calendar.dateBetween(cell.date, start.date, end.date))
            cell.addClass('selected');
          else
            cell.removeClass('selected');
        }
      });
    });
    if (full_row)
      fillRange(first, last);
    else {
      _currentSectionView = calendar._setView(start.date, end.date);
      _dateStart = calendar.curRangeStart;
      _dateEnd = calendar.curRangeEnd;
    }
  }

  void setRange(DateTime start, DateTime end) {
    rows.forEach((row) {
      row.forEach((cell) {
        if (utils.Calendar.dateBetween(cell.date, start, end))
          cell.addClass('selected');
        else
          cell.removeClass('selected');
      });
    });
  }

  void startDrag(CalendarHelperCell cell) {
    startCell = cell;
    _clear();
    cell.addClass('selected');
    over(cell);
  }

  void over(CalendarHelperCell cell) {
    if (startCell == null) return;
    if (cell.date.isAfter(startCell!.date))
      fillRange(
          startCell!, cell, cell.date.difference(startCell!.date).inDays > 6);
    else
      fillRange(
          cell, startCell!, startCell!.date.difference(cell.date).inDays > 6);
  }

  Future<void> render([bool load = true]) async {
    calendar
      ..curRangeStart = _dateStart!
      ..curRangeEnd = _dateEnd!
      .._currentView = () => render(false);
    _currentSectionView!();
    if (load)
      await calendar.loadEvents(calendar.curRangeStart, calendar.curRangeEnd);
    calendar.renderEvents();
  }
}
