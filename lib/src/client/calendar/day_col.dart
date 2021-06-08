part of calendar;

class DayCol extends CLElement {
  late DateTime date;

  EventCalendar calendar;

  late EventCollection evCol;

  late FilterCollection fCol;

  late CLElement outer, dayCont, dayDrag;

  final List<CLElement> _rendered = [];

  DayCol(date, this.calendar) : super(new html.Element.td()) {
    evCol = new EventCollection()..days = false;
    fCol = new FilterCollection()..days = false;
    this.date = EventCalendar.normDate(date);
    outer = new CLElement(new html.DivElement())
      ..setClass('day-container')
      ..appendTo(this);
    dayCont = new CLElement(new html.DivElement())
      ..setClass('day-inner')
      ..appendTo(outer);
    if (!calendar._weeklyMode && calendar.now.compareTo(this.date) == 0) {
      addClass('now');
      final mark = new CLElement(new html.DivElement())..setClass('hour-mark');
      final top = calendar.timeToPixels(new DateTime.now());
      mark.setStyle({'top': '${top}px'});
      outer.append(mark);
    }
    if (calendar.filters.isNotEmpty) addClass('filter');
    dayDrag = new CLElement(new html.DivElement())
      ..setClass('day-container-drag')
      ..appendTo(this);
  }

  List<Event> _intersectEvents(List<Event> events) {
    if (events.isEmpty) return [];
    final inter = <Event>[];
    events.forEach((event) {
      if (!event.isAllDayEvent() &&
          (date.compareTo(EventCalendar.normDate(event.start)) == 0 ||
              date.compareTo(EventCalendar.normDate(event.end)) == 0))
        inter.add(event);
    });
    return inter;
  }

  List<Filter> _intersectFilters(List<Filter> filters) {
    if (filters.isEmpty) return [];
    final inter = <Filter>[];
    final range_first = date;
    final range_last = date.add(const Duration(minutes: 24 * 60 - 1));
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
    if (events.isNotEmpty) evCol.events.addAll(_intersectEvents(events));
  }

  void setFilters(List<Filter> filters) {
    fCol
      ..rendered = new Expando()
      ..filters = <Filter>[];
    if (filters.isNotEmpty) fCol.filters.addAll(_intersectFilters(filters));
  }

  Map<int, List<Event>> _readEvents(List<Event> events) {
    var row = 0;
    final m = <int, List<Event>>{};
    while (!evCol.isEventsRendered()) {
      row++;
      m[row] = <Event>[];
      var ev = evCol.getNextEvent(true);
      while (ev != null) {
        evCol.rendered[ev] = true;
        m[row]!.add(ev);
        ev = evCol.getNextEventEqualSibling(ev, true);
      }
    }
    return m;
  }

  void render() {
    outer.removeChildsByClass('filter-cont');
    dayCont.removeChilds();

    if (fCol.filters.isNotEmpty) fCol.filters.forEach(_renderFilter);

    if (evCol.events.isEmpty) return;
    final data = _readEvents(evCol.events);

    int neighborsCount(DateTime date, DateTime end, int exclude) {
      final rule1 = (event) =>
          evCol._compare(event.start, date) > 0 &&
          evCol._compare(event.start, end) < 0;
      final rule2 = (event) =>
          evCol._compare(event.end, date) > 0 &&
          evCol._compare(event.end, end) < 0;
      final rule3 = (event) =>
          evCol._compare(event.start, date) <= 0 &&
          evCol._compare(event.end, end) >= 0;
      var i = 1;
      data.forEach((k, v) {
        if (k != exclude &&
            v.any((event) => rule1(event) || rule2(event) || rule3(event))) i++;
      });
      return i;
    }

    data.forEach((cur_row, events) {
      final k = cur_row - 1;
      events.forEach((event) {
        var width_av = 100.0;
        var width = 100.0;
        final length = neighborsCount(event.start, event.end, cur_row);
        if (length > 1) {
          width_av = 100 / length;
          width = (85 / length) * 2;
        }
        if (cur_row == length) width = width_av;
        _renderEvent(event, k * width_av, width);
      });
    });
  }

  void _renderFilter(Filter filter) {
    final indx_start = utils.Calendar.max(
        filter.start, new DateTime(date.year, date.month, date.day, 0, 0));
    final indx_end = utils.Calendar.min(
        filter.end, new DateTime(date.year, date.month, date.day, 24, 0));

    final top = calendar.timeToPixels(indx_start);
    final diff = evCol._diff(indx_start, indx_end);
    final height = math.max(calendar.hourGridMinutes, diff) /
        calendar.hourGridMinutes *
        calendar.hourSectionHeight;

    final cont = new CLElement(new html.DivElement())
      ..addClass('filter-cont')
      ..setStyle({'top': '${top}px', 'height': '${height}px'});
    outer.append(cont);
  }

  void _renderEvent(Event event, num left, num width) {
    if (calendar.dayCont!.doms[event] == null)
      calendar.dayCont!.doms[event] = [];
    final indx_start = utils.Calendar.max(
        event.start, new DateTime(date.year, date.month, date.day, 0, 0));
    final indx_end = utils.Calendar.min(
        event.end, new DateTime(date.year, date.month, date.day, 24, 0));

    final top = calendar.timeToPixels(indx_start);
    final diff = evCol._diff(indx_start, indx_end);
    final height = math.max(calendar.hourGridMinutes, diff) /
        calendar.hourGridMinutes *
        calendar.hourSectionHeight;

    final cont = new CLElement(new html.DivElement())
      ..addClass('event-cont-hour ${event.color}')
      ..addAction<html.Event>((e) => e.stopPropagation(), 'mousedown')
      ..addAction((e) => event._contrClick.add(null), 'click')
      ..addAction((e) {
        calendar.editEvent(event);
        event._contrDblClick.add(null);
      }, 'dblclick');
    _rendered.add(cont);
    new CLElement(new html.DivElement())
      ..addClass('inner')
      ..setText(event.title)
      ..appendTo(cont);
    final resize = new CLElement(new html.DivElement())
      ..addClass('resize')
      ..addAction<html.Event>((e) => e.stopPropagation(), 'mousedown')
      ..setText('=')
      ..appendTo(cont);
    calendar.dayCont!.doms[event]!.add(cont);
    cont.setStyle({
      'top': '${top}px',
      'left': '$left%',
      'width': '$width%',
      'height': '${height}px'
    });
    dayCont.append(cont);

    if (!event.draggable) return;

    new utils.Drag(cont)
      ..start((e) => calendar.dayCont!
          .moveSet(event, e.client.x.toInt(), e.client.y.toInt()))
      ..on(
          (e) => calendar.dayCont!.move(e.client.x.toInt(), e.client.y.toInt()))
      ..end(calendar.dayCont!.release);
    new utils.Drag(resize)
      ..start((e) => calendar.dayCont!.resizeSet(event))
      ..on((e) =>
          calendar.dayCont!.resize(e.client.x.toInt(), e.client.y.toInt()))
      ..end(calendar.dayCont!.release);
  }

  void clean() => _rendered.forEach((el) => el.remove());
}
