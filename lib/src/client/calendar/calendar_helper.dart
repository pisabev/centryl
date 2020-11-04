part of calendar;

class CalendarHelper extends CLElement {
  DateTime cur;

  EventCalendar calendar;

  CLElement<TableSectionElement> domTbody;
  CLElement<Element> domMonth;

  CalendarHelperDrag drag;

  DateTime rangeStart;
  DateTime rangeEnd;

  CalendarHelper(this.calendar) : super(new DivElement()) {
    setClass('ui-calendar-helper');
    cur = new DateTime.now();
    createDom();
  }

  void createDom() {
    final nav = new CLElement(new DivElement())
      ..setClass('cal-nav')
      ..appendTo(this);

    new action.Button()
      ..setIcon(Icon.chevron_left)
      ..addAction((e) {
        e.stopPropagation();
        cur = new DateTime(cur.year, cur.month - 1);
        set();
      }, 'mouseup')
      ..appendTo(nav);
    new action.Button()
      ..setIcon(Icon.chevron_right)
      ..addAction((e) {
        e.stopPropagation();
        cur = new DateTime(cur.year, cur.month + 1);
        set();
      }, 'mouseup')
      ..appendTo(nav);
    final label_month = new CLElement(new ParagraphElement())..appendTo(nav);

    final table = new CLElement<TableElement>(new TableElement())
      ..appendTo(this);
    final thead = new CLElement<TableSectionElement>(table.dom.createTHead())
          ..appendTo(table),
        tbody = new CLElement<TableSectionElement>(table.dom.createTBody())
          ..appendTo(table);

    final row = thead.dom.insertRow(-1);
    for (var day = 0; day < 7; day++) {
      row.insertCell(-1)
        ..className = utils.Calendar.isWeekend(day) ? 'weekend' : ''
        ..innerHtml = utils.Calendar.getDayStringVeryShortByNum(day);
    }
    domMonth = label_month;
    domTbody = tbody;
  }

  void set() {
    domTbody.removeChilds();
    domMonth.dom.text =
        '${utils.Calendar.getMonthString(cur.month)} ${cur.year}';
    final offset =
        new DateTime(cur.year, cur.month).weekday - utils.Calendar.offset();
    var k = -1;
    TableRowElement row;
    final rows = new List.generate(6, (_) => <CalendarHelperCell>[]);
    for (var i = 0; i < 42; i++) {
      row = (i % 7 == 0) ? domTbody.dom.insertRow(-1) : row;
      if (i % 7 == 0) k++;
      final c = row.insertCell(-1)
        ..className = utils.Calendar.isWeekend(i % 7) ? 'weekend' : '';
      final cell = new CalendarHelperCell(
          new SpanElement(), new DateTime(cur.year, cur.month, i - offset))
        ..appendTo(c);
      if (cell.date.month != cur.month) cell.addClass('other');
      if (checkDateForEvents(cell.date)) c.className = 'events';
      if (cell.date.isAtSameMomentAs(calendar.now)) cell.addClass('today');
      cell.setText('${cell.date.day}');
      rows[k].add(cell);
    }
    drag = new CalendarHelperDrag(rows)
      ..calendar = calendar
      ..setDraggable();
    if (rangeStart != null && rangeEnd != null)
      drag.setRange(rangeStart, rangeEnd);
  }

  void setRange(DateTime cur_view, [DateTime start, DateTime end]) {
    cur = cur_view;
    rangeStart = start;
    rangeEnd = end;
    set();
  }

  bool checkDateForEvents(DateTime date) => calendar.events.any((event) {
        if (utils.Calendar.dateBetween(date, event.start, event.end) ||
            date.year == event.start.year &&
                date.month == event.start.month &&
                date.day == event.start.day) return true;
        return false;
      });
}
