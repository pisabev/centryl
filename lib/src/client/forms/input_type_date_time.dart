part of forms;

class _InputTypeDateTime implements _InputTypeBase<DateTime> {
  List<DateTime?>? range;
  bool inclusive;
  DateTime? value;

  _InputTypeDateTime([this.range, this.inclusive = false]) {
    if (range != null) {
      if (range![0] is DateTime) {
        final d = range![0]!.isUtc ? range![0]!.toLocal() : range![0]!;
        range![0] = new DateTime(d.year, d.month, d.day, d.hour, d.minute);
      }
      if (range![1] is DateTime) {
        final d = range![1]!.isUtc ? range![1]!.toLocal() : range![1]!;
        range![1] = new DateTime(d.year, d.month, d.day, d.hour, d.minute);
      }
    }
  }

  void set(dynamic v) {
    if (v is String)
      value = utils.Calendar.parseWithTime(v);
    else if (v is DateTime) {
      final d = v.isUtc ? v.toLocal() : v;
      value = new DateTime(d.year, d.month, d.day, d.hour, d.minute);
    } else {
      value = null;
    }
  }

  String toString() =>
      value == null ? '' : utils.Calendar.stringWithTime(value);

  FutureOr<bool> validateValue(DateTime v) {
    if (range != null)
      return ((range![0] is DateTime && _checkAfter(v, range![0]!)) ||
              range![0] == null) &&
          ((range![1] is DateTime && _checkBefore(v, range![1]!)) ||
              range![1] == null);
    return true;
  }

  bool _checkAfter(DateTime v, DateTime to) =>
      inclusive ? v.isAfter(to) || v.isAtSameMomentAs(to) : v.isAfter(to);

  bool _checkBefore(DateTime v, DateTime to) =>
      inclusive ? v.isBefore(to) || v.isAtSameMomentAs(to) : v.isBefore(to);

  bool validateInput(html.KeyboardEvent e) =>
      utils.KeyValidator.isNum(e) ||
      utils.KeyValidator.isColon(e) ||
      utils.KeyValidator.isSlash(e);
}
