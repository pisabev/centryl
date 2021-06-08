part of forms;

class _InputTypeDate implements _InputTypeBase<DateTime> {
  List<DateTime?>? range;
  bool inclusive;
  DateTime? value;

  _InputTypeDate([this.range, this.inclusive = false]) {
    if (range != null) {
      if (range![0] is DateTime) {
        final v = range![0]!.isUtc ? range![0]!.toLocal() : range![0]!;
        range![0] = new DateTime(v.year, v.month, v.day);
      }
      if (range![1] is DateTime) {
        final v = range![1]!.isUtc ? range![1]!.toLocal() : range![1]!;
        range![1] = new DateTime(v.year, v.month, v.day);
      }
    }
  }

  void set(dynamic v) {
    if (v is String)
      value = utils.Calendar.parse(v);
    else if (v is DateTime) {
      final d = v.isUtc ? v.toLocal() : v;
      value = new DateTime(d.year, d.month, d.day);
    } else {
      value = null;
    }
  }

  String toString() => value == null ? '' : utils.Calendar.string(value);

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

  bool validateInput(html.Event e) =>
      utils.KeyValidator.isNum(e as html.KeyboardEvent) ||
      utils.KeyValidator.isSlash(e);
}
