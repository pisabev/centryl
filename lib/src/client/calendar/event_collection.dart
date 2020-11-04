part of calendar;

class EventCollection {
  List<Event> events = [];

  Expando rendered = new Expando();

  bool days = true;

  List<Event> getEarliestEvents(List<Event> events, [bool noRendered = false]) {
    if (events.isEmpty) return [];
    final temp = noRendered
        ? events.where((event) => !_isRendered(event)).toList()
        : events;
    if (temp.isEmpty) return [];
    DateTime min;
    temp.forEach((event) {
      final m = (min == null) ? event.start : _min(event.start, min);
      min = days ? EventCalendar.normDate(m) : m;
    });
    return temp
        .where((event) =>
            (days ? EventCalendar.normDate(event.start) : event.start)
                .isAtSameMomentAs(min))
        .toList();
  }

  Event getLongestEvent(List<Event> events, [bool noRendered = false]) {
    if (events.isEmpty) return null;
    final temp = noRendered
        ? events.where((event) => !_isRendered(event)).toList()
        : events;
    if (temp.isEmpty) return null;
    var max = 0;
    temp.forEach((event) => max = math.max(_diff(event.start, event.end), max));
    return temp.firstWhere((event) => _diff(event.start, event.end) == max);
  }

  List<Event> getEventsInSpot(DateTime date, [bool noRendered = false]) =>
      noRendered
          ? events
              .where((event) =>
                  !_isRendered(event) && (_compare(event.start, date) == 0))
              .toList()
          : events.where((event) => _compare(event.start, date) == 0).toList();

  List<Event> getEventsAfterSpot(DateTime date, [bool noRendered = false]) =>
      noRendered
          ? events
              .where((event) =>
                  !_isRendered(event) && (_compare(event.start, date) > 0))
              .toList()
          : events.where((event) => _compare(event.start, date) > 0).toList();

  List<Event> getEventsAfterEqualSpot(DateTime date,
          [bool noRendered = false]) =>
      noRendered
          ? events
              .where((event) =>
                  !_isRendered(event) && (_compare(event.start, date) >= 0))
              .toList()
          : events.where((event) => _compare(event.start, date) >= 0).toList();

  int _diff(DateTime date_start, DateTime date_end) => days
      ? EventCalendar.normDate(date_end)
          .difference(EventCalendar.normDate(date_start))
          .inDays
      : date_end.difference(date_start).inMinutes;

  int _compare(DateTime first, DateTime second) => days
      ? EventCalendar.normDate(first).compareTo(EventCalendar.normDate(second))
      : first.compareTo(second);

  DateTime _min(DateTime first, DateTime second) =>
      _compare(first, second) < 0 ? first : second;

  bool _isRendered(Event event) => rendered[event] != null && rendered[event];

  bool isEventsRendered() => events.every(_isRendered);

  Event getNextEvent([bool noRendered = false]) =>
      getLongestEvent(getEarliestEvents(events, noRendered));

  Event getNextEventSibling(Event event, [bool noRendered = false]) =>
      getLongestEvent(
          getEarliestEvents(getEventsAfterSpot(event.end, noRendered)));

  Event getNextEventEqualSibling(Event event, [bool noRendered = false]) =>
      getLongestEvent(
          getEarliestEvents(getEventsAfterEqualSpot(event.end, noRendered)));
}
