part of calendar;

class Event {
  late Object id;

  String color = 'color1';

  late DateTime _start, _end, startPrev, endPrev;

  bool draggable = true;

  String title;

  bool full_day;

  Object? data;

  final StreamController<void> _contrClick = new StreamController.broadcast();
  final StreamController<void> _contrDblClick =
      new StreamController.broadcast();

  Event(this.title, DateTime start, DateTime end, [this.full_day = false]) {
    _start = utils.Calendar.min(start, end).toLocal();
    _end = utils.Calendar.max(start, end).toLocal();
    startPrev = _start;
    endPrev = _end;
  }

  Stream<void> get onClick => _contrClick.stream;

  Stream<void> get onDblClick => _contrDblClick.stream;

  String toString() => '$title: $_start - $_end';

  DateTime get start => _start;

  set start(DateTime s) {
    startPrev = _start;
    _start = s;
  }

  DateTime get end => _end;

  set end(DateTime s) {
    endPrev = _end;
    _end = s;
  }

  bool isPassed() {
    final now = new DateTime.now();
    return now.compareTo(_end) > 0;
  }

  bool isAllDayEvent() => full_day;

  bool changed() =>
      !_start.isAtSameMomentAs(startPrev) || !_end.isAtSameMomentAs(endPrev);
}
