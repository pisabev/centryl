part of calendar;

abstract class EventCalendar<E extends Event> {
  late Container dom, nav, body;
  CLElement<html.TableElement>? head;
  late CLElement domMonth;

  utils.CLscroll? _scroll;

  List<E> events = [];

  List<Filter> filters = [];

  late DateTime now, cur;

  late action.Button contrLeft, contrRight;

  late CalendarHelper calendarHelper;

  late action.ButtonGroup button;

  late MonthContainer montCont;
  DayContainer? dayCont;

  late DateTime curRangeStart, _curRangeEnd;

  bool _weeklyMode = false;
  bool noMonth = false;

  num hourRowHeight = 0;
  late num hourSectionHeight;
  late num _pixelPerMinute;
  int hourGridMinutes = 30;

  num? _zoom;

  late Function _currentView;

  EventCalendar(CLElement container) {
    dom = new Container()
      ..appendTo(container)
      ..addClass('ui-event-calendar');
    nav = new Container()..setClass('cal-navigation');
    body = new Container()..setClass('cal-body');
    dom..addRow(nav)..addRow(body..auto = true);

    final n = new DateTime.now();
    now = new DateTime(n.year, n.month, n.day);
    cur = now;

    calendarHelper = new CalendarHelper(this)..set();

    final helper = new action.Button();
    helper
      ..setIcon(Icon.today)
      ..addAction((e) {
        final scr = new utils.UISlider(calendarHelper, helper, appendDom: true)
          ..show();
        late CLElement doc;
        doc = new CLElement(html.document.body)
          ..addAction((e) {
            scr.hide();
            doc.removeAction('mouseup.select');
          }, 'mouseup.select');
      })
      ..appendTo(nav);

    new action.Button()
      ..setTitle(intl.Today())
      ..addAction((e) {
        cur = new DateTime.now();
        button.current?.dom.click();
        calendarHelper
          ..cur = cur
          ..set();
      })
      ..appendTo(nav);

    contrLeft = new action.Button()
      ..setIcon(Icon.chevron_left)
      ..appendTo(nav);

    contrRight = new action.Button()
      ..setIcon(Icon.chevron_right)
      ..appendTo(nav);

    button = new action.ButtonGroup()
      ..addSub(new action.Button()
        ..setTitle(intl.Month())
        ..addAction((e) => setViewMonth()))
      ..addSub(new action.Button()
        ..setTitle(intl.Week())
        ..addAction((e) => setViewWeek()))
      ..addSub(new action.Button()
        ..setTitle(intl.Day())
        ..addAction((e) => setViewDay()))
      ..setCurrent(1);

    domMonth = new CLElement(new html.ParagraphElement())..appendTo(nav);

    button.appendTo(nav);
  }

  EventCalendar.weekly(Container container, [bool load = true]) {
    dom = new Container()
      ..appendTo(container)
      ..addClass('ui-event-calendar');
    body = new Container()..setClass('cal-body');
    dom.addCol(body..auto = true);
    _weeklyMode = true;
    final n = new DateTime.now();
    now = new DateTime(n.year, n.month, n.day);
    cur = now;
    _weekly(load);
  }

  DateTime get curRangeEnd => _curRangeEnd;

  set curRangeEnd(DateTime date) =>
      _curRangeEnd = new DateTime(date.year, date.month, date.day, 23, 59, 59);

  Future<void> _weekly([bool load = true]) async {
    _currentView = () => _weekly(false);
    final dates = _weekSlices(cur);
    _setViewDays(dates.first.first, dates.first.last);
    if (load) await loadEvents(curRangeStart, curRangeEnd);
    renderEvents();
  }

  void createEvent(DateTime start_date, DateTime end_date,
      [bool full_day = false]) {
    //events.add(new Event('Untitled', start_date, end_date, full_day));
  }

  void editEvent(E event);

  Future persistEvent(E event);

  Future loadEvents(DateTime start, DateTime end);

  void renderEvents() {
    montCont?.rows.forEach((r) {
      r
        ..setFilters(filters)
        ..setEvents(events)
        ..render();
    });
    if (dayCont != null) {
      dayCont!.cols.forEach((dc) {
        dc
          ..setFilters(filters)
          ..setEvents(events)
          ..render();
      });
    }
  }

  void scale(num zoom) {
    _zoom = zoom;
    hourRowHeight = 0;
    _currentView();
  }

  Future setViewMonth([bool load = true]) async {
    _currentView = () => setViewMonth(false);
    button.setCurrent(0);
    _setViewMonth();
    if (load) await loadEvents(curRangeStart, curRangeEnd);
    calendarHelper.setRange(cur, curRangeStart, curRangeEnd);
    renderEvents();
  }

  Future setViewWeek([bool load = true]) async {
    _currentView = () => setViewWeek(false);
    button.setCurrent(1);
    final dates = _weekSlices(cur);
    _setViewDays(dates.first.first, dates.first.last);
    if (load) await loadEvents(curRangeStart, curRangeEnd);
    calendarHelper.setRange(dates.first.last, curRangeStart, curRangeEnd);
    renderEvents();
  }

  Future setViewDay([bool load = true]) async {
    _currentView = () => setViewDay(false);
    button.setCurrent(2);
    _setViewDays(cur);
    if (load) await loadEvents(curRangeStart, curRangeEnd);
    calendarHelper.setRange(cur, cur, cur);
    renderEvents();
  }

  Function _setView(DateTime start_date, DateTime end_date) {
    button.setCurrent();
    if (start_date.difference(end_date).inDays.abs() > 6) {
      final start_slice = _weekSlices(start_date).first;
      final end_slice = _weekSlices(end_date).first;
      final start = new DateTime(cur.year, cur.month, 1);
      final end = utils.Calendar.UTCAdd(
          start,
          utils.Calendar.UTCDifference(
              new DateTime(cur.year, cur.month + 1, 0), start));
      if (start_slice.any((date) => start.compareTo(date) == 0) &&
          end_slice.any((date) => end.compareTo(date) == 0)) {
        button.setCurrent(0);
        _setViewMonth();
        return _setViewMonth;
      } else {
        _setViewMonthSection(start_date, end_date);
        return () => _setViewMonthSection(start_date, end_date);
      }
    } else {
      _setViewDays(start_date, end_date);
      return () => _setViewDays(start_date, end_date);
    }
  }

  void _setViewMonth() {
    contrLeft
      ..removeActionsAll()
      ..addAction((e) async {
        cur = new DateTime(cur.year, cur.month - 1);
        _setViewMonth();
        await loadEvents(curRangeStart, curRangeEnd);
        calendarHelper.setRange(cur, curRangeStart, curRangeEnd);
        renderEvents();
      }, 'click');
    contrRight
      ..removeActionsAll()
      ..addAction((e) async {
        cur = new DateTime(cur.year, cur.month + 1);
        _setViewMonth();
        await loadEvents(curRangeStart, curRangeEnd);
        calendarHelper.setRange(cur, curRangeStart, curRangeEnd);
        renderEvents();
      }, 'click');
    _setTitle(cur);
    _prepareViewMonth();

    final rows = <MonthRow>[];
    final cells = <MonthCell>[];

    final prelist = new List.generate(6, (_) => <DateTime>[]);
    final offset =
        new DateTime(cur.year, cur.month).weekday - utils.Calendar.offset();
    var k = -1;
    for (var i = 0; i < 42; i++) {
      if (i % 7 == 0) k++;
      prelist[k].add(new DateTime(cur.year, cur.month, i - offset));
    }
    final month_rows = <List<DateTime>>[];
    prelist.forEach((dates) {
      if (dates.any((date) => date.month == cur.month)) month_rows.add(dates);
    });

    final height = ((new CLElement(body.dom).getHeightComputed() -
                (head?.getHeight() ?? 0)) /
            month_rows.length)
        .ceil();
    month_rows.forEach((row) {
      final el = new MonthRow(row, this)
        ..appendTo(body)
        ..setHeight(new Dimension.px(height));
      montCont.setDragable(el);
      cells.addAll(el.cells);
      rows.add(el);
    });
    montCont
      ..rows = rows
      ..cells = cells;
    dayCont = null;

    curRangeStart = month_rows.first.first;
    curRangeEnd = month_rows.last.last;
  }

  void _setViewMonthSection(DateTime start_date, DateTime end_date) {
    _setContr(start_date, end_date, _setViewMonthSection);
    _setTitle(start_date, end_date);
    _prepareViewMonth();

    final rows = <MonthRow>[], cells = <MonthCell>[];
    cur = end_date;
    final month_rows = _weekSlices(start_date, end_date);
    final height =
        ((body.dom.offsetHeight - (head?.getHeight() ?? 0)) / month_rows.length)
            .ceil();
    month_rows.forEach((row) {
      final el = new MonthRow(row, this)
        ..appendTo(body)
        ..setHeight(new Dimension.px(height));
      montCont.setDragable(el);
      cells.addAll(el.cells);
      rows.add(el);
    });
    montCont
      ..rows = rows
      ..cells = cells;
    dayCont = null;
  }

  void _setViewDays(DateTime start_date, [DateTime? end_date]) {
    end_date ??= start_date;

    curRangeStart = start_date;
    curRangeEnd = end_date;

    start_date = normDateUtc(start_date);
    end_date = normDateUtc(end_date);

    _setContr(start_date, end_date, _setViewDays);
    if (!_weeklyMode) _setTitle(start_date, end_date);

    end_date = end_date.add(const Duration(days: 1));

    final dates = <DateTime>[];
    var next_date = start_date;
    while (next_date.compareTo(end_date) != 0) {
      dates.add(next_date);
      next_date = next_date.add(const Duration(days: 1));
    }
    var scrollTop = _scroll?.containerEl.scrollTop;
    body.removeChilds();

    if (!noMonth) {
      head = new CLElement(new html.TableElement())
        ..setClass('week-head')
        ..appendTo(body);
    }

    final weekDom = new CLElement(new html.DivElement())
      ..setClass('week-cont')
      ..appendTo(body);
    final table_scroll =
        new CLElement<html.TableElement>(new html.TableElement())
          ..setClass('week-scroll')
          ..appendTo(weekDom);

    late CLElement<html.TableSectionElement> tbody_top;
    if (head != null) {
      new CLElement(head!.dom.createTHead()).appendTo(head);
      tbody_top =
          new CLElement<html.TableSectionElement>(head!.dom.createTBody())
            ..appendTo(head);
    }

    new CLElement(table_scroll.dom.createTHead()).appendTo(table_scroll);
    final tbody =
        new CLElement<html.TableSectionElement>(table_scroll.dom.createTBody())
          ..appendTo(table_scroll);

    html.TableRowElement? row;
    if (!noMonth) {
      row = tbody_top.dom.insertRow(-1);
      final first = (new html.Element.th() as html.TableCellElement)
        ..className = 'first'
        ..rowSpan = 2;
      row.append(first);
    }

    final row_scroll_first = tbody.dom.insertRow(-1);
    final row_scroll = tbody.dom.insertRow(-1);

    final first_scroll = new html.TableCellElement()
      ..className = 'first_scroll';
    final first_scroll2 = new html.TableCellElement()
      ..className = 'first_scroll2'
      ..colSpan = dates.length;

    row_scroll_first..append(first_scroll)..append(first_scroll2);

    final hour = new html.Element.td()..className = 'first';
    final dayDom = new CLElement(new html.DivElement())..setClass('day');
    row_scroll.append(hour);
    first_scroll2.append(dayDom.dom);

    final hour_rows = <HourRow>[];
    for (var i = 0; i < 24; i++) {
      final t = new CLElement(new html.DivElement())
        ..setClass('hour')
        ..dom.text = '$i:00';
      hour.append(t.dom);

      if (hourRowHeight == 0) {
        hourRowHeight = t.getHeightComputed();
        if (_zoom != null) hourRowHeight *= _zoom!;
      }

      if (_zoom != null) t.setHeight(new Dimension.px(hourRowHeight));

      for (var j = 0; j < 60 / hourGridMinutes; j++) {
        hourSectionHeight = hourRowHeight / (60 / hourGridMinutes);
        final hr = new HourRow(i, j * hourGridMinutes)
          ..setHeight(new Dimension.px(hourSectionHeight));
        dayDom.append(hr);
        hour_rows.add(hr);
      }
    }

    _pixelPerMinute = 60 / hourRowHeight;

    if (!_weeklyMode && !noMonth) {
      final mark = new CLElement(new html.DivElement())..setClass('hour-mark');
      hour.append(mark.dom);
      mark.setStyle({
        'top': '${timeToPixels(new DateTime.now()) - mark.getHeight() / 2}px'
      });

      final row_top_events = head!.dom.insertRow(-1);
      final cell_top_events = new html.TableCellElement()
        ..colSpan = dates.length;
      row_top_events.append(cell_top_events);
      new CLElement(new html.DivElement())
        ..appendTo(body)
        ..setClass('closing');

      montCont = new MonthContainer(body, this);
      final month_row = new WeekRow(dates, this)..appendTo(cell_top_events);
      montCont
        ..setDragable(month_row)
        ..cells = month_row.cells
        ..rows = [month_row];
    }

    dayCont = new DayContainer(this)
      ..hourRows = hour_rows
      ..cols = []
      ..setDragable(dayDom);
    for (var day = 0; day < dates.length; day++) {
      final cell = new html.Element.th();
      row?.append(cell);
      final dc = new DayCol(dates[day], this);
      dayCont?.cols.add(dc..appendTo(row_scroll));
      if (!_weeklyMode)
        cell.text = '${utils.Calendar.getDayStringShort(dates[day].weekday)}'
            ' ${dates[day].month}/${dates[day].day}';
      else
        cell.text = '${utils.Calendar.getDayString(dates[day].weekday)}';
      cell.className =
          utils.Calendar.isWeekendFromDate(dates[day].weekday) ? 'weekend' : '';
    }

    _scroll = new utils.CLscroll(weekDom.dom);
    if (dayCont?.cols.length == 1 && dayCont!.cols.first.existClass('now'))
      scrollTop = timeToPixels(new DateTime.now());
    if (scrollTop != null) _scroll?.containerEl.scrollTop = scrollTop;
  }

  void _prepareViewMonth() {
    body.removeChilds();
    head = new CLElement(new html.TableElement())
      ..setClass('cal-head')
      ..appendTo(body);
    final thead =
        new CLElement<html.TableSectionElement>(head!.dom.createTHead())
          ..appendTo(head);
    new CLElement(head!.dom.createTBody()).appendTo(head);

    final row = thead.dom.insertRow(-1);
    for (var day = 0; day < 7; day++) {
      final cell = new html.Element.th();
      row.append(cell);
      cell
        ..text = utils.Calendar.getDayStringShortByNum(day)
        ..className = utils.Calendar.isWeekend(day) ? 'weekend' : '';
    }

    montCont = new MonthContainer(body, this);
  }

  List<List<DateTime>> _weekSlices(DateTime start, [DateTime? end]) {
    DateTime _firstDate(DateTime date) => new DateTime(date.year, date.month,
        date.day - (date.weekday - utils.Calendar.weekDayFirst()));

    DateTime _endDate(DateTime date) => new DateTime(date.year, date.month,
        date.day - (date.weekday - utils.Calendar.weekDayLast()));

    end ??= start;
    start = _firstDate(start);
    end = _endDate(end);
    final list = <List<DateTime>>[];
    var k = -1;
    for (var i = 0; i < 42; i++) {
      final cur = new DateTime(start.year, start.month, start.day + i);
      if (i % 7 == 0) k++;
      if (list.length <= k) list.add([]);
      list[k].add(cur);
      if (cur.isAtSameMomentAs(end)) break;
    }
    return list;
  }

  void _setContr(DateTime start, DateTime end, callback) {
    final step = utils.Calendar.UTCDifference(start, end).inDays.abs() + 1;
    contrLeft
      ..removeActionsAll()
      ..addAction((e) async {
        start = new DateTime(start.year, start.month, start.day - step);
        end = new DateTime(end.year, end.month, end.day - step);
        callback(start, end);
        curRangeStart = start;
        curRangeEnd = end;
        await loadEvents(curRangeStart, curRangeEnd);
        calendarHelper.setRange(end, start, end);
        renderEvents();
        cur = end;
      }, 'click');
    contrRight
      ..removeActionsAll()
      ..addAction((e) async {
        start = new DateTime(start.year, start.month, start.day + step);
        end = new DateTime(end.year, end.month, end.day + step);
        callback(start, end);
        curRangeStart = start;
        curRangeEnd = end;
        await loadEvents(curRangeStart, curRangeEnd);
        calendarHelper.setRange(end, start, end);
        renderEvents();
        cur = end;
      }, 'click');
  }

  void _setTitle(DateTime start, [DateTime? end]) {
    if (end == null) {
      domMonth.setHtml(
          '${utils.Calendar.getMonthString(start.month)} ${start.year}');
    } else if (start.compareTo(end) == 0) {
      domMonth.setHtml('${utils.Calendar.getDayString(start.weekday)}, '
          '${utils.Calendar.getMonthStringShort(start.month)} '
          '${start.day}, ${start.year}');
    } else {
      final month_start = utils.Calendar.getMonthStringShort(start.month);
      final month_end = end.month == start.month
          ? ''
          : ' ${utils.Calendar.getMonthStringShort(end.month)} ';
      final year_start = end.year == start.year ? '' : ', ${start.year}';
      domMonth.setHtml('$month_start '
          '${start.day}$year_start - $month_end${end.day}, '
          '${end.year}');
    }
  }

  int timeToPixels(DateTime date) =>
      ((date.hour * 60 + date.minute) ~/ _pixelPerMinute).toInt();

  static DateTime normDate(DateTime date) =>
      new DateTime(date.year, date.month, date.day);

  static DateTime normDateUtc(DateTime date) =>
      new DateTime.utc(date.year, date.month, date.day);

  static DateTime normDateFull(DateTime date) => new DateTime(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond);

  static DateTime normDateFullUtc(DateTime date) => new DateTime.utc(
      date.year,
      date.month,
      date.day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond);

  void changed() => calendarHelper.set();

  Future refresh() async {
    montCont.rows.forEach((r) => r.clean());
    if (dayCont != null) dayCont!.cols.forEach((d) => d.clean());
    await loadEvents(curRangeStart, curRangeEnd);
    _currentView();
  }

  void layout() {
    if (_currentView != null) _currentView();
  }
}
