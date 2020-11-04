part of calendar;

class FilterCollection {
  List<Filter> filters = [];

  Expando rendered = new Expando();

  bool days = true;

  List<Filter> getEarliestFilters(List<Filter> filters,
      [bool noRendered = false]) {
    if (filters.isEmpty) return [];
    final temp = noRendered
        ? filters.where((filter) => !_isRendered(filter)).toList()
        : filters;
    if (temp.isEmpty) return [];
    DateTime min;
    temp.forEach((filter) {
      final m = (min == null) ? filter.start : _min(filter.start, min);
      min = days ? EventCalendar.normDate(m) : m;
    });
    return temp
        .where((filter) =>
            (days ? EventCalendar.normDate(filter.start) : filter.start)
                .isAtSameMomentAs(min))
        .toList();
  }

  Filter getLongestFilter(List<Filter> filters, [bool noRendered = false]) {
    if (filters.isEmpty) return null;
    final temp = noRendered
        ? filters.where((filter) => !_isRendered(filter)).toList()
        : filters;
    if (temp.isEmpty) return null;
    var max = 0;
    temp.forEach(
        (filter) => max = math.max(_diff(filter.start, filter.end), max));
    return temp.firstWhere((filter) => _diff(filter.start, filter.end) == max);
  }

  List<Filter> getFiltersInSpot(DateTime date, [bool noRendered = false]) =>
      noRendered
          ? filters
              .where((filter) =>
                  !_isRendered(filter) && (_compare(filter.start, date) == 0))
              .toList()
          : filters
              .where((filter) => _compare(filter.start, date) == 0)
              .toList();

  List<Filter> getFiltersAfterSpot(DateTime date, [bool noRendered = false]) =>
      noRendered
          ? filters
              .where((filter) =>
                  !_isRendered(filter) && (_compare(filter.start, date) > 0))
              .toList()
          : filters
              .where((filter) => _compare(filter.start, date) > 0)
              .toList();

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

  bool _isRendered(Filter filter) =>
      rendered[filter] != null && rendered[filter];

  bool isFiltersRendered() => filters.every(_isRendered);

  Filter getNextFilter([bool noRendered = false]) =>
      getLongestFilter(getEarliestFilters(filters, noRendered));

  Filter getNextFilterSibling(Filter filter, [bool noRendered = false]) =>
      getLongestFilter(
          getEarliestFilters(getFiltersAfterSpot(filter.end, noRendered)));

  bool inRange(DateTime start, DateTime end) => filters.any((filter) =>
      start.compareTo(filter.start) >= 0 && end.compareTo(filter.end) <= 0);

  bool outOfRange(DateTime start, DateTime end) => filters.any((filter) =>
      start.compareTo(filter.end) >= 0 || end.compareTo(filter.start) <= 0);
}
