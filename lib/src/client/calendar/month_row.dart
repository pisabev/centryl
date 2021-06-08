part of calendar;

class MonthRow extends CLElement {
  late CLElement<html.TableElement> tableMain, tableGrid;

  late CLElement<html.TableSectionElement> tbodyMain, tbodyGrid;

  late CLElement filterCont;

  EventCalendar calendar;

  late EventCollection evCol;

  late FilterCollection fCol;

  late List<DateTime> dates;

  final List<MonthCell> cells = [];

  final List<CLElement> _rendered = [];

  Map<String, List> counter = {};

  int _limit = 0;

  gui.Pop? pop;

  MonthRow(List<DateTime> dates, this.calendar) : super(new html.DivElement()) {
    evCol = new EventCollection();
    fCol = new FilterCollection();
    this.dates = dates.map(EventCalendar.normDate).toList();
    createDom();
    filterCont = new CLElement(new html.DivElement())..setClass('filter-cont');
    append(filterCont);
  }

  void createDom() {
    addClass('cal-row');
    tableMain = new CLElement(new html.TableElement())
      ..appendTo(this)
      ..addClass('cal-back');
    tableGrid = new CLElement(new html.TableElement())
      ..appendTo(this)
      ..addClass('cal-grid');
    tbodyMain = new CLElement(tableMain.dom.createTBody())..appendTo(tableMain);
    tbodyGrid = new CLElement(tableMain.dom.createTBody())..appendTo(tableGrid);
    final row_main = tbodyMain.dom.insertRow(-1);
    final row_grid_title = tbodyGrid.dom.insertRow(-1);

    for (var i = 0; i < dates.length; i++) {
      final cell = new MonthCell(row_main.insertCell(-1), dates[i]);
      if (calendar.filters.isNotEmpty) cell.addClass('filter');
      if (dates[i].compareTo(calendar.now) == 0) cell.addClass('now');
      cells.add(cell);
      final title = row_grid_title.insertCell(-1);
      if (dates[i].month != calendar.cur.month) {
        title.className = 'blur';
        if (dates[i].day == 1)
          title.innerHtml =
              '${utils.Calendar.getMonthStringShort(dates[i].month)}'
              ' ${dates[i].day}';
        else
          title.innerHtml = '${dates[i].day}';
      } else
        title.innerHtml = '${dates[i].day}';
    }
  }

  void setHeight(Dimension dim) {
    super.setHeight(dim);
    final test = new CLElement(new html.DivElement())
      ..setClass('event-cont')
      ..append(new html.SpanElement()..text = 'test');
    tbodyMain.dom.children.first.children.first.append(test.dom);
    _limit = (dim.value / (test.getHeight() + 1)).floor() - 1;
    test.remove();
  }

  MonthCell getMonthCell(DateTime date) =>
      cells.firstWhere((mc) => mc.date.compareTo(date) == 0);

  List<Event> _intersectEvents(List<Event> events) {
    if (events.isEmpty) return [];
    final inter = <Event>[];
    final range_first = dates.first;
    final range_last = dates.last;
    events.forEach((event) {
      final event_start = EventCalendar.normDate(event.start);
      final event_end = EventCalendar.normDate(event.end);
      if (utils.Calendar.dateBetween(event_start, range_first, range_last) ||
          utils.Calendar.dateBetween(event_end, range_first, range_last) ||
          utils.Calendar.dateBetween(range_first, event_start, event_end)) {
        inter.add(event);
      }
    });
    return inter;
  }

  List<Filter> _intersectFilters(List<Filter> filters) {
    if (filters.isEmpty) return [];
    final inter = <Filter>[];
    final range_first = dates.first;
    final range_last = dates.last;
    filters.forEach((filter) {
      final event_start = EventCalendar.normDate(filter.start);
      final event_end = EventCalendar.normDate(filter.end);
      if (utils.Calendar.dateBetween(event_start, range_first, range_last) ||
          utils.Calendar.dateBetween(event_end, range_first, range_last) ||
          utils.Calendar.dateBetween(range_first, event_start, event_end)) {
        inter.add(filter);
      }
    });
    return inter;
  }

  void setEvents(List<Event> events) {
    evCol
      ..rendered = new Expando()
      ..events = <Event>[];
    if (events.isNotEmpty) {
      evCol.events.addAll(_intersectEvents(events));
    }
  }

  void setFilters(List<Filter> filters) {
    fCol
      ..rendered = new Expando()
      ..filters = <Filter>[];
    if (filters.isNotEmpty) fCol.filters.addAll(_intersectFilters(filters));
  }

  List<List<Event>> _readEvents(List<Event> events) {
    final l = <List<Event>>[];
    counter = {};
    while (!evCol.isEventsRendered()) {
      final l_inner = <Event>[];
      l.add(l_inner);
      var ev = evCol.getNextEvent(true);
      while (ev != null) {
        evCol.rendered[ev] = true;
        l_inner.add(ev);
        dates.forEach((date) {
          if (utils.Calendar.dateBetweenDay(
              date,
              EventCalendar.normDate(ev!.start),
              EventCalendar.normDate(ev.end))) {
            final k = date.toString();
            if (counter[k] == null) counter[k] = [];
            counter[k]!.add(ev);
          }
        });
        ev = evCol.getNextEventSibling(ev, true);
      }
    }
    return l;
  }

  void _reset() {
    filterCont.removeChilds();
    // Skip the first row;
    tbodyGrid.dom.children
        .removeWhere((ch) => ch.previousElementSibling != null);
  }

  void render() {
    _reset();

    if (fCol.filters.isNotEmpty) {
      fCol.filters.forEach((filter) {
        var filterStart = EventCalendar.normDate(filter.start);
        var filterEnd = EventCalendar.normDate(filter.end);
        filterStart = utils.Calendar.max(filterStart, dates.first);
        filterEnd = utils.Calendar.min(filterEnd, dates.last);
        final startCell = getMonthCell(EventCalendar.normDate(filterStart));
        final endCell = getMonthCell(EventCalendar.normDate(filterEnd));
        highLight(startCell, endCell, filterCont);
      });
    }

    if (evCol.events.isEmpty) return;
    final data = _readEvents(evCol.events);

    // Mark events that should not be rendered
    var draw_rows = 0;
    final ignored_events = <Event>[];
    counter.forEach((date, events) {
      if (_limit != 0) {
        if (events.length > _limit) {
          var iterations = events.length - _limit;
          var last = events.length - 1;
          while (iterations-- > -1) {
            final event = events[last--];
            if (!ignored_events.contains(event)) ignored_events.add(event);
          }
        }
        draw_rows = math.max(draw_rows, math.min(events.length, _limit));
      } else {
        draw_rows = math.max(draw_rows, events.length);
      }
    });

    // Hidden events
    final hidden_counter = <String, List<Event>>{};
    ignored_events.forEach((event) {
      counter.forEach((date, events) {
        if (events.contains(event)) {
          if (hidden_counter[date] == null) hidden_counter[date] = <Event>[];
          hidden_counter[date]!.add(event);
        }
      });
    });

    // Create Table Row/Cell initial structure
    final rows = <html.TableRowElement>[];
    for (var i = 0; i < draw_rows; i++) {
      final row = tbodyGrid.dom.insertRow(-1);
      rows.add(row);
      for (var j = 0; j < dates.length; j++) row.insertCell(-1);
    }

    // Render events
    var k = 0;
    data.forEach((event_row) {
      if (k == rows.length) return;
      final row = rows[k++];
      event_row.forEach((event) {
        final event_start = EventCalendar.normDate(event.start);
        final event_end = EventCalendar.normDate(event.end);
        final indx_start = utils.Calendar.max(event_start, dates.first);
        final indx_end = utils.Calendar.min(event_end, dates.last);
        final cell = new CLElement<html.TableCellElement>(
            getIndexByDate(row, indx_start))
          ..addAction<html.Event>((e) => e.stopPropagation(), 'mousedown');
        if (ignored_events.contains(event)) return;
        final r = evCol._diff(indx_start, indx_end) + 1;
        cell.dom.colSpan = r;
        cell.setClass('event');
        final div =
            _eventDom(event, event_start, event_end, indx_start, indx_end);
        cell.append(div);
        _rendered.add(div);

        var i = 0;
        while (i < r - 1) {
          cell.dom.nextElementSibling?.remove();
          i++;
        }
      });
    });

    if (rows.isEmpty) return;
    final row = rows.last;
    for (var i = 0; i < row.children.length; i++) {
      if (hidden_counter.containsKey(dates[i].toString())) {
        final h_l = hidden_counter[dates[i].toString()];
        new CLElement(new html.AnchorElement())
          ..addClass('more')
          ..setText(intl.more_events(h_l!.length))
          ..addAction<html.Event>(
              (e) => _renderHidden(e, dates[i], h_l), 'mousedown')
          ..appendTo(row.children[i]);
      }
    }
  }

  void highLight(MonthCell start, MonthCell end, CLElement container) {
    cells.forEach((cell) {
      if (utils.Calendar.dateBetween(cell.date, start.date, end.date)) {
        final rect = cell.dom.offset;
        new CLElement(new html.DivElement())
          ..setStyle({'width': '${rect.width}px', 'left': '${rect.left}px'})
          ..appendTo(container);
      }
    });
  }

  CLElement _eventDom(
      Event event, event_start, event_end, indx_start, indx_end) {
    final div = new CLElement(new html.DivElement())
      ..setClass('event-cont ${event.color}');
    if (event.isPassed()) div.addClass('light');
    if (event.isAllDayEvent()) {
      if (indx_start.compareTo(event_start) > 0) {
        new CLElement(new html.DivElement())
          ..setClass('arrow-left1')
          ..appendTo(div);
        new CLElement(new html.DivElement())
          ..setClass('arrow-left2')
          ..appendTo(div);
        div.addClass('margin-left');
      }
      if (indx_end.compareTo(event_end) < 0) {
        new CLElement(new html.DivElement())
          ..setClass('arrow-right1')
          ..appendTo(div);
        new CLElement(new html.DivElement())
          ..setClass('arrow-right2')
          ..appendTo(div);
        div.addClass('margin-right');
      }
    } else {
      div.addClass('day');
    }

    div
      ..append(new html.SpanElement()..text = event.title)
      ..addAction((e) => event._contrClick.add(null), 'click')
      ..addAction((e) {
        calendar.editEvent(event);
        event._contrDblClick.add(null);
      }, 'dblclick');

    if (!event.draggable) return div;

    late CLElement drg;
    late html.Rectangle rect;

    void setDragPos(CLElement drg, html.Rectangle rect, html.MouseEvent e) =>
        drg.setStyle({
          'top': '${e.page.y - rect.top - 10}px',
          'left': '${e.page.x - rect.left - 50}px'
        });

    new utils.Drag(div)
      ..start((e) {
        drg = new CLElement(new html.DivElement())
          ..setClass('event-cont ${event.color} drag')
          ..setText(event.title);
        //.appendTo(div);
        rect = div.getRectangle();
        //setDragPos(drg, rect, e);
        //calendar.dragm.onDragEvent(e, event);
      })
      ..on((e) {
        div.append(drg);
        setDragPos(drg, rect, e);
        calendar.montCont.onDragEvent(e, event);
        if (pop != null) {
          pop!.close();
          pop = null;
        }
      })
      ..end((e) {
        drg.remove();
        calendar.montCont.onDropEvent(e, event);
      });
    return div;
  }

  void _renderHidden(html.Event e, DateTime date, List<Event> events) {
    e
      ..preventDefault()
      ..stopPropagation();
    pop?.close();
    final cont = new CLElement(new html.DivElement())
      ..setClass('ui-event-popup');
    final title = '${utils.Calendar.getDayString(date.weekday)}, '
        '${date.day} ${utils.Calendar.getMonthString(date.month)} ${date.year}';
    final title_dom = new CLElement(new html.DivElement())
      ..setClass('title')
      ..setText(title)
      ..append(new CLElement(new html.AnchorElement())
        ..addAction((e) {
          pop?.close();
        }));
    cont.append(title_dom);
    events.forEach((event) {
      final event_start = EventCalendar.normDate(event.start);
      final event_end = EventCalendar.normDate(event.end);
      final indx_start = utils.Calendar.max(event_start, date);
      final indx_end = utils.Calendar.min(event_end, date);
      cont.append(
          _eventDom(event, event_start, event_end, indx_start, indx_end));
    });
    pop = new gui.Pop(cont, e);
  }

  void clean() => _rendered.forEach((el) => el.remove());

  html.TableCellElement? getIndexByDate(
      html.TableRowElement row, DateTime date) {
    final indx = dates.indexOf(date);
    if (indx == 0) return row.cells[indx];
    var index = 0;
    for (var i = 0; i < row.cells.length; i++) {
      if (index == indx) return row.cells[i];
      index += row.cells[i].colSpan;
    }
    return null;
  }
}
