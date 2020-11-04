part of calendar;

class DayContainer {
  List<HourRow> hourRows;
  List<DayCol> cols;

  List<DayRectContainter> rects;

  Event eventSel;

  EventCalendar calendar;

  DateTime startDate, endDate, clickDate;

  Expando<List> doms = new Expando();
  List<CLElement> dm = [];

  DayContainer(this.calendar);

  void moveSet(Event event, int x, int y) {
    eventSel = event;
    clickDate = getDateByCoords(x, y);
    startDate = eventSel.start;
    endDate = eventSel.end;
    //doms[event].forEach((dom) => dom.hide());
    _drawRects(eventSel.start, eventSel.end);
  }

  void move(int x, int y) {
    final cur = getDateByCoords(x, y);
    if (cur == null) return;
    final diff = cur.difference(clickDate);
    doms[eventSel].forEach((dom) => dom.hide());
    _drawRects(eventSel.start.add(diff), eventSel.end.add(diff));
  }

  void resizeSet(Event event) {
    eventSel = event;
    startDate = eventSel.start;
    endDate = eventSel.end;
    doms[event].forEach((dom) => dom.hide());
    _drawRects(eventSel.start, eventSel.end);
  }

  void resize(int x, int y) {
    final stretch_date = getDateByCoords(x, y);
    _drawRects(eventSel.start, stretch_date);
  }

  Future release(MouseEvent e) async {
    if (startDate == null ||
        endDate == null ||
        startDate.compareTo(endDate) > 0) return;
    if (eventSel != null) {
      eventSel
        ..start = startDate
        ..end = endDate;
      if (eventSel.changed()) await calendar.persistEvent(eventSel);
    } else
      calendar.createEvent(startDate, endDate, false);
    //calendar.removeEvent(eventSel);
    dm.forEach((d) => d.remove());
    dm = [];
    cols.forEach((dc) {
      dc
        ..setEvents(calendar.events)
        ..render();
    });
    calendar.changed();
    startDate = null;
    endDate = null;
    eventSel = null;
  }

  void setDragable(CLElement dc) {
    DateTime date1;
    DateTime date2;
    dc.addAction<MouseEvent>((e) {
      final date = getDateByCoords(e.client.x, e.client.y);
      if (calendar.filters.isNotEmpty &&
          !cols.any((d) => d.fCol.inRange(date, date))) return;
      startDate = date;
      endDate = date.add(new Duration(minutes: calendar.hourGridMinutes));
      release(e);
    }, 'dblclick');
    new utils.Drag(dc)
      ..start((e) => date1 = getDateByCoords(e.client.x, e.client.y))
      ..on((e) {
        date2 = getDateByCoords(e.client.x, e.client.y);
        if (date1 != null && date2 != null)
          _drawRects(utils.Calendar.min(date1, date2),
              utils.Calendar.max(date1, date2));
      })
      ..end(release);
  }

  void _drawRects(DateTime start, DateTime end) {
    if (start == null ||
        end == null ||
        start.compareTo(end) > 0 ||
        end.difference(start).inHours > 23) return;
    if (calendar.filters.isNotEmpty &&
        !cols.any((d) => d.fCol.inRange(start, end))) return;
    startDate = start;
    endDate = end;
    rects = getDayRectByDates(start, end);
    dm.forEach((d) => d.remove());
    dm = [];
    rects.forEach((rect) {
      if (rect != null) {
        final drag_cont = rect.day.dayDrag;
        final t = drag_cont.getRectangle();
        final rectangle = rect.rect
          ..top -= t.top
          ..left = 0;
        final e = new CLElement(new DivElement())
          ..setClass('day-event')
          ..setRectangle(rectangle)
          ..appendTo(drag_cont);
        dm.add(e);
      }
    });
  }

  HourRow getHourByCoords(int x, int y) => hourRows.firstWhere(
      (row) => row.getRectangle().containsPoint(new math.Point(x, y)),
      orElse: () => null);

  DayCol getDayByCoords(int x, int y) => cols.firstWhere(
      (col) => col.getRectangle().containsPoint(new math.Point(x, y)),
      orElse: () => null);

  HourRow getHourRowByDate(DateTime date) {
    var hour = date.hour;
    var minute = date.minute;
    if (date.minute > 60 - calendar.hourGridMinutes) {
      hour += 1;
      minute = 0;
    } else if (date.minute > 0) {
      minute = calendar.hourGridMinutes;
    }
    return hourRows.firstWhere(
        (row) => row.hour == hour && row.minutes == minute,
        orElse: () => null);
  }

  DayCol getDayColByDate(DateTime date) => cols
      .firstWhere((day) => day.date.day == date.day, orElse: () => null);

  DateTime getDateByCoords(int x, int y) {
    final row = getHourByCoords(x, y);
    final day = getDayByCoords(x, y);
    if (row == null || day == null) return null;
    return new DateTime(
        day.date.year, day.date.month, day.date.day, row.hour, row.minutes);
  }

  List<DayRectContainter> getDayRectByDates(
      DateTime date_start, DateTime date_end) {
    if (date_start.day != date_end.day) {
      final startDate_end = new DateTime(
          date_start.year, date_start.month, date_start.day, 23, 59);
      final endDate_start =
          new DateTime(date_end.year, date_end.month, date_end.day, 0, 0);
      final f = getDayRectByDates(date_start, startDate_end);
      final s = getDayRectByDates(endDate_start, date_end);
      return [f.first, s.first];
    } else {
      final r = getHourRowByDate(date_start);
      final d = getDayColByDate(date_start);
      if (r == null || d == null) return [null];
      final rect = r.getRectangle().intersection(d.getRectangle());
      final offset_date = new DateTime(
          d.date.year, d.date.month, d.date.day, r.hour, r.minutes);
      final top = rect.top -
          (offset_date.difference(date_start).inMinutes /
                  calendar._pixelPerMinute)
              .ceil();
      final diff = math.max(
          date_end.difference(date_start).inMinutes, calendar.hourGridMinutes);
      return [
        new DayRectContainter()
          ..rect = new math.MutableRectangle(rect.left, top, rect.width,
              (diff / calendar._pixelPerMinute).ceil())
          ..day = d
          ..row = r
      ];
    }
  }
}

class DayRectContainter {
  math.MutableRectangle rect;
  DayCol day;
  HourRow row;
}
