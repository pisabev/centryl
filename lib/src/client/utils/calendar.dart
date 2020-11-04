part of utils;

class Calendar {
  static bool firstDayMonday = true;

  static List<Map<String, dynamic>> ranges = [
    {'title': intl.Tomorrow(), 'method': getTomorrowRange},
    {'title': intl.Today(), 'method': getTodayRange},
    {'title': intl.Yesterday(), 'method': getYesterdayRange},
    {'title': intl.One_week_back(), 'method': getWeeksBackRange},
    {'title': intl.This_week(), 'method': getThisWeekRange},
    {'title': intl.Last_week(), 'method': getLastWeekRange},
    {'title': intl.One_month_back(), 'method': getMonthsBackRange},
    {'title': intl.This_month(), 'method': getThisMonthRange},
    {'title': intl.Last_month(), 'method': getLastMonthRange},
    {'title': intl.One_year_back(), 'method': getYearsBackRange},
    {'title': intl.This_year(), 'method': getThisYearRange},
    {'title': intl.Last_year(), 'method': getLastYearRange},
    {'title': intl.All(), 'method': getAllRange}
  ];

  static Duration UTCDifference(DateTime date1, DateTime date2) =>
      normDateFullUtc(date1).difference(normDateFullUtc(date2));

  static DateTime UTCAdd(DateTime date, Duration dur) {
    final utc = normDateFullUtc(date).add(dur);
    return normDateFull(utc);
  }

  static DateTime UTCSub(DateTime date, Duration dur) {
    final utc = normDateFullUtc(date).subtract(dur);
    return normDateFull(utc);
  }

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

  static int weekDayFirst() => firstDayMonday ? 1 : 0;

  static int weekDayLast() => firstDayMonday ? 7 : 6;

  static DateTime max(DateTime d1, DateTime d2) {
    final diff = d1.compareTo(d2);
    return (diff > 0) ? d1 : d2;
  }

  static DateTime min(DateTime d1, DateTime d2) {
    final diff = d1.compareTo(d2);
    return (diff < 0) ? d1 : d2;
  }

  static bool dateBetween(DateTime date, DateTime end1, DateTime end2) {
    final start = min(end1, end2);
    final end = max(end1, end2);
    if (date.isAfter(start) && date.isBefore(end) ||
        date.compareTo(start) == 0 ||
        date.compareTo(end) == 0) return true;
    return false;
  }

  static bool dateBetweenDay(DateTime date, DateTime end1, DateTime end2) {
    final start = min(end1, end2);
    final end = max(end1, end2);
    if (date.isAfter(start) && date.isBefore(end) ||
        date.compareTo(start) == 0 ||
        date.compareTo(end) == 0) return true;
    return false;
  }

  static int offset() => firstDayMonday ? 2 : 1;

  static bool isWeekend(int num) {
    if (firstDayMonday) {
      if (num == 5 || num == 6) return true;
    } else {
      if (num == 0 || num == 6) return true;
    }
    return false;
  }

  static bool isWeekendFromDate(int weekday) {
    if (weekday == 6 || weekday == 7) return true;
    return false;
  }

  static String textChoosePeriod() => intl.Choose_period();

  static String textToday() => intl.today();

  static String textEmpty() => intl.empty();

  static String textDone() => intl.done();

  static List<DateTime> _getRange(DateTime d, DateTime n) => [d, n];

  static DateTime parse(String date) {
    DateTime d;
    try {
      d = DateTime.parse(date);
      if (d.isUtc) d = d.toLocal();
      d = new DateTime(d.year, d.month, d.day);
    } catch (e) {
      try {
        d = new DateFormat('dd/MM/yyyy').parse(date);
      } catch (e) {
        d = null;
      }
    }
    return d;
  }

  static DateTime parseWithTime(String date) {
    DateTime d;
    try {
      d = DateTime.parse(date);
      if (d.isUtc) d = d.toLocal();
      d = new DateTime(d.year, d.month, d.day, d.hour, d.minute);
    } catch (e) {
      try {
        d = new DateFormat('dd/MM/yyyy HH:mm').parse(date);
      } catch (e) {
        try {
          d = new DateFormat('dd/MM/yyyy mm').parse(date);
        } catch (e) {
          d = null;
        }
      }
    }
    return d;
  }

  static DateTime parseWithTimeFull(String date) {
    DateTime d;
    try {
      d = DateTime.parse(date);
      if (d.isUtc) d = d.toLocal();
      d = new DateTime(d.year, d.month, d.day, d.hour, d.minute, d.second);
    } catch (e) {
      try {
        d = new DateFormat('dd/MM/yyyy HH:mm:ss').parse(date);
      } catch (e) {
        d = null;
      }
    }
    return d;
  }

  static DateTime parseYear(String date) {
    DateTime d;
    try {
      d = new DateFormat('yyyy').parse(date);
    } catch (e) {
      d = null;
    }
    return d;
  }

  static DateTime parseYearMonth(String date) {
    DateTime d;
    try {
      d = new DateFormat('yyyy-MM').parse(date);
    } catch (e) {
      d = null;
    }
    return d;
  }

  static DateTime fromDateAndMinutes(DateTime date, int minutes) =>
      new DateTime(date.year, date.month, date.day, 0, minutes).toUtc();

  static String string(DateTime date) {
    if (date == null) return '';
    return new DateFormat('dd/MM/yyyy').format(date);
  }

  static String stringWithTime(DateTime date) {
    if (date == null) return '';
    return new DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String stringWithTimeFull(DateTime date) {
    if (date == null) return '';
    return new DateFormat('dd/MM/yyyy HH:mm:ss').format(date);
  }

  static String getTime(DateTime date) => new DateFormat('HH:mm').format(date);

  static List<DateTime> getDateRange([DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(d, d);
  }

  static List<DateTime> getMonthRange([DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(
        new DateTime(d.year, d.month, 1),
        new DateTime(
            d.year, d.month, new DateTime(d.year, d.month + 1, 0).day));
  }

  static List<DateTime> getYearRange([DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(new DateTime(d.year, 0, 1), new DateTime(d.year, 11, 31));
  }

  static List<DateTime> getWeeksBackRange([int diff = 1, DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(d.subtract(new Duration(days: diff * 7)), d);
  }

  static List<DateTime> getMonthsBackRange([int diff = 1, DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(d.subtract(new Duration(days: diff * 30)), d);
  }

  static List<DateTime> getYearsBackRange([int diff = 1, DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(d.subtract(new Duration(days: diff * 365)), d);
  }

  static List<DateTime> getTodayRange([DateTime d]) {
    d ??= new DateTime.now();
    return _getRange(d, d);
  }

  static List<DateTime> getTomorrowRange([DateTime d]) {
    d ??= new DateTime.now();
    final d1 = new DateTime(d.year, d.month, d.day + 1);
    return _getRange(d1, d1);
  }

  static List<DateTime> getYesterdayRange([DateTime d]) {
    d ??= new DateTime.now();
    d = d.subtract(const Duration(days: 1));
    return _getRange(d, d);
  }

  static List<DateTime> getThisWeekRange([DateTime n]) {
    n ??= new DateTime.now();
    var diff = n.weekday - 1;
    diff = (diff < 0) ? 6 : diff;
    final d = n.subtract(new Duration(days: diff));
    return _getRange(d, n);
  }

  static List<DateTime> getLastWeekRange([DateTime d]) {
    d ??= new DateTime.now();
    var n = cloneDate(d);
    n = n.subtract(new Duration(days: n.weekday));
    d = n.subtract(const Duration(days: 6));
    return _getRange(d, n);
  }

  static List<DateTime> getThisMonthRange([DateTime n]) {
    n ??= new DateTime.now();
    final d = new DateTime(n.year, n.month, 1);
    return _getRange(d, n);
  }

  static List<DateTime> getLastMonthRange([DateTime h]) {
    h ??= new DateTime.now();
    var n = new DateTime(h.year, h.month, 1);
    n = n.subtract(const Duration(days: 1));
    final d = new DateTime(n.year, n.month, 1);
    return _getRange(d, n);
  }

  static List<DateTime> getThisYearRange([DateTime n]) {
    n ??= new DateTime.now();
    final d = new DateTime(n.year, 1, 1);
    return _getRange(d, n);
  }

  static List<DateTime> getLastYearRange([DateTime h]) {
    h ??= new DateTime.now();
    final d = new DateTime(h.year - 1, 1, 1);
    final n = new DateTime(h.year - 1, 12, 31);
    return _getRange(d, n);
  }

  static DateTime cloneDate(DateTime date) =>
      new DateTime.fromMicrosecondsSinceEpoch(date.microsecondsSinceEpoch,
          isUtc: date.isUtc);

  static List<DateTime> getAllRange() =>
      _getRange(new DateTime(2000, 0, 1), new DateTime.now());

  static String getDayString(int weekday) =>
      new DateFormat().dateSymbols.WEEKDAYS[(weekday == 7 ? 0 : weekday)];

  static String getDayStringShortByNum(int num) {
    if (firstDayMonday) {
      num += 1;
      if (num > 6) num = 0;
    }
    return new DateFormat().dateSymbols.SHORTWEEKDAYS[num];
  }

  static String getDayStringShort(int weekday) =>
      new DateFormat().dateSymbols.SHORTWEEKDAYS[(weekday == 7 ? 0 : weekday)];

  static String getDayStringVeryShortByNum(int num) {
    if (firstDayMonday) {
      num += 1;
      if (num > 6) num = 0;
    }
    return new DateFormat().dateSymbols.NARROWWEEKDAYS[num];
  }

  static String getDayStringVeryShort(int weekday) =>
      new DateFormat().dateSymbols.NARROWWEEKDAYS[(weekday == 7 ? 0 : weekday)];

  static String getMonthString(int month) =>
      new DateFormat().dateSymbols.MONTHS[month - 1];

  static String getMonthStringShort(int month) =>
      new DateFormat().dateSymbols.SHORTMONTHS[month - 1];
}
