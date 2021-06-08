part of calendar;

class Filter {
  late DateTime start, end;

  String title;

  bool full_day;

  Filter(this.title, DateTime start, DateTime end, [this.full_day = false]) {
    this.start = utils.Calendar.min(start, end).toLocal();
    this.end = utils.Calendar.max(start, end).toLocal();
  }

  String toString() => '$title: $start - $end';
}
