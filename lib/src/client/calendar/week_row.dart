part of calendar;

class WeekRow extends MonthRow {
  WeekRow(dates, calendar) : super(dates, calendar);

  List<Event> _intersectEvents(List<Event> events) {
    if (events.isEmpty) return [];
    final inter = <Event>[];
    final range_first = dates.first;
    final range_last = dates.last;
    events.forEach((event) {
      final event_start = EventCalendar.normDate(event.start);
      final event_end = EventCalendar.normDate(event.end);
      if (event.isAllDayEvent() &&
          (utils.Calendar.dateBetween(event_start, range_first, range_last) ||
              utils.Calendar.dateBetween(event_end, range_first, range_last) ||
              utils.Calendar.dateBetween(
                  range_first, event_start, event_end))) {
        inter.add(event);
      }
    });
    return inter;
  }

  void createDom() {
    addClass('cal-row week');
    tableMain = new CLElement(new html.TableElement())
      ..appendTo(this)
      ..addClass('cal-back week');
    tableGrid = new CLElement(new html.TableElement())
      ..appendTo(this)
      ..addClass('cal-grid week');
    tbodyMain = new CLElement(tableMain.dom.createTBody())..appendTo(tableMain);
    tbodyGrid = new CLElement(tableMain.dom.createTBody())..appendTo(tableGrid);
    final row_main = tbodyMain.dom.insertRow(-1);
    final row_grid_title = tbodyGrid.dom.insertRow(-1);

    for (var i = 0; i < dates.length; i++) {
      final cell = new MonthCell(row_main.insertCell(-1), dates[i]);
      if (dates[i].compareTo(calendar.now) == 0) {
        cell
          ..addClass('now')
          ..append(new html.SpanElement());
      }
      if (calendar.filters.isNotEmpty) cell.addClass('filter');
      cells.add(cell);
      row_grid_title.insertCell(-1);
    }
  }

  void render() {
    super.render();
    tableMain.setStyle(
        {'height': '${new CLElement(tbodyGrid.dom).getHeightComputed()}px'});
    //calendar.setBodyHeight();
  }
}
